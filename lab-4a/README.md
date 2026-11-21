# Lab 4A: MVC and MVVM

## Architecture Diagrams

MVC Flow:
[TaskBoardView] --(User Events)--> [TaskListViewController] --(Updates)--> [TaskItem Array]
       ^                                      |
       +--------(Manual tableView.reloadData)-+

MVVM Flow:
[MVVMTaskListView] <--(@Published Bindings)--> [TaskViewModel] --(Mutates)--> [TaskItem Array]
(Pure Rendering)                               (Validation, Filtering, State)

## MVC vs. MVVM Comparison (R5)

| Dimension | MVC (UIKit) | MVVM (SwiftUI + ObservableObject) |
| :--- | :--- | :--- |
| Testability | Low without UI hosting: validation and filtering live inside `TaskListViewController`, requiring `loadViewIfNeeded()` and `UITableView` lifecycle setup to test. | High: `TaskViewModel` is a plain Swift class that can be unit-tested directly (`runTaskViewModelUnitChecks()`) without rendering any views. |
| Responsibility Boundaries | `TaskListViewController` acts as both UI coordinator and business-logic handler (managing validation, filtering, and data-source methods). | `MVVMTaskListView` handles layout and user gestures only; `TaskViewModel` owns state, input validation, and filtering. |
| Amount of Wiring Required | Explicit imperative wiring: `addTarget`, `UITableViewDataSource`/`Delegate`, index synchronization between `allTasks` and `visibleTasks`, and manual `reloadData()`. | Declarative two-way bindings (`$viewModel.draftTitle`, `$viewModel.selectedFilter`) automatically re-render the list whenever `@Published` properties change. |
