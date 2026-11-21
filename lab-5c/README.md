# Lab 5C: Task Groups and Structured Concurrency

## Sequential vs. Concurrent Timing Comparison (R3)

With 4 courses and a simulated 400 ms network delay per course:

| Execution Strategy | Mechanism | Simulated Delay per Item | Total Elapsed Time |
| :--- | :--- | :--- | :--- |
| Sequential (`fetchSequentially`) | `for-in` loop with `await` | 400 ms x 4 | ~1.62 seconds |
| Concurrent (`withThrowingTaskGroup`) | 4 parallel child tasks | 400 ms (overlapped) | ~0.41 seconds |
| Bounded Concurrent (`maxConcurrent = 2`) | Sliding window of 2 tasks (5 items) | 400 ms in 3 waves | ~1.22 seconds |

Sample Test Output:
Sequential fetched 4 courses.
Sequential Elapsed Time: 1.624 seconds
Concurrent fetched 4 courses in order: ["IOS-101", "IOS-202", "IOS-303", "IOS-404"]
Concurrent Elapsed Time: 0.412 seconds
All-or-Nothing Strategy Aborted: Course IOS-303 could not be retrieved from server
Partial Strategy Succeeded (3): ["IOS-101", "IOS-202", "IOS-404"]
Partial Strategy Failed (1): ["Course IOS-303 could not be retrieved from server"]
Max-Concurrency (2) fetched 5 courses.
Bounded Concurrency (max 2) Elapsed Time: 1.219 seconds

## Child Task Failure Handling Policy (R4)

We implemented and compared two explicit policies:
1. Partial-Results Policy (`withTaskGroup` returning `Result<ModuleMetadata, CatalogFetchError>`): Chosen for catalog browsing screens. One failing endpoint (`IOS-303`) is captured as `.failure` without cancelling sibling tasks, allowing the UI to display the 3 available courses plus a warning for the failed item.
2. Fail-Fast Policy (`withThrowingTaskGroup`): Chosen when all records are required together (e.g., checkout or batch validation). When `IOS-303` throws, the group cancels all remaining in-flight sibling tasks immediately and rethrows the error.

## Cancellation and Task Lifetime (R5)

- Structured Lifetime: A `TaskGroup` strictly scopes all child tasks to the `withTaskGroup` / `withThrowingTaskGroup` closure. Swift guarantees that every child task completes or is cancelled before the task group function returns—no child task can outlive its parent scope or leak background work.
- Cancellation Propagation: If the parent `Task` is cancelled—or if one child throws an uncaught error in `withThrowingTaskGroup`—Swift automatically marks all sibling child tasks as cancelled. Inside `fetchCourseDetail`, `Task.sleep` and `try Task.checkCancellation()` respond cooperatively and exit early with `CancellationError`.
