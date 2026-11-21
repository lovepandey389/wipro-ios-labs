# Milestone 2: Architecture and Concurrency

## R4: Why UI Updates Belong on the Main Actor / Main Queue

1. Thread-Safety of UI Frameworks: UIKit and SwiftUI view hierarchies, layout passes, and Core Animation layer trees are not thread-safe. Mutating `@Published` view state or `UIView` properties from a background thread causes data races, visual glitches, and dropped frames.
2. Synchronized Frame Commits: The main run loop coordinates touch handling, layout calculation, and display rendering on a single serial thread (`DispatchQueue.main` / `@MainActor`). Marking `MilestoneTaskViewModel` with `@MainActor` guarantees that all state mutations (`items`, `syncPhase`) automatically hop back to the main thread after `await` resumes.

## R5: Viva Comparison — GCD vs. async/await vs. Task vs. TaskGroup

| Concept | Role & Execution Model | Key Strengths & Trade-offs |
| :--- | :--- | :--- |
| GCD (`DispatchQueue`) | Low-level C-based FIFO queue API (`global`, `main`, `asyncAfter`, `DispatchGroup`). | Fine-grained QoS control, but nested callbacks ("pyramid of doom"), manual cancellation flags, and no compile-time data-race safety. |
| `async/await` | Language-level syntax for non-blocking suspension (`async let` runs fixed child operations concurrently). | Linear, readable code with automatic error propagation (`throws`), eliminating callback nesting. |
| `Task` | Unit of asynchronous execution that bridges synchronous code (like button taps) into `async` contexts. | Supports cooperative cancellation (`task.cancel()`) and priority inheritance, but unstructured if detached. |
| `TaskGroup` (`withTaskGroup`) | Structured concurrency container for a dynamic number of parallel child tasks. | Guarantees all child tasks finish or cancel before the scope exits, preventing leaked background work. |
