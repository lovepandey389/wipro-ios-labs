# Lab 5B: async/await and Task

## Four UI States Demonstrated (R3)

1. Loading: Displays a `ProgressView` while `fetchCourses(scenario:)` suspends and disables duplicate load requests until completion or cancellation.
2. Success: Renders the returned `[TrainingCourse]` list after `await` resumes with non-empty data.
3. Empty: Displays an empty-state placeholder when the async fetch succeeds with `[]`.
4. Failure: Displays the error message alongside a Retry button when `fetchCourses(scenario:)` throws `CatalogServiceError.networkUnreachable`.

## Cooperative Cancellation (R4)

- Tapping Cancel invokes `activeTask?.cancel()`, marking the running `Task` as cancelled.
- Inside `fetchCourses(scenario:)`, both `Task.sleep` and `try Task.checkCancellation()` immediately throw `CancellationError` when cancelled, preventing stale results from overwriting the UI.

## Difference Between Declaring an `async` Function and Creating a `Task` (R5)

- Declaring an `async` function (`func fetchCourses(...) async throws`) only defines asynchronous work that is allowed to suspend at `await` points; calling it does not start concurrent execution on its own and can only be invoked from an already-asynchronous context.
- Creating a `Task { ... }` schedules and launches a new top-level unit of asynchronous work from a synchronous context (such as a SwiftUI button tap), returning a `Task` handle that can be stored, awaited, or cancelled (`activeTask?.cancel()`).
