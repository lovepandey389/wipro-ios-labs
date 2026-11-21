# Lab 2B: Closures

## Closure Parameters & Syntax (R1 & R3)

- Shorthand & Trailing Closure: In `cohort.sorted { $0.grade > $1.grade }`, Swift infers parameter and return types from `sorted(by:)`, allowing trailing-closure syntax and `$0`/`$1` shorthand names.
- Explicit Parameter Names: Rewriting the sort as `{ (firstTrainee: Trainee, secondTrainee: Trainee) -> Bool in ... }` makes input types and return values self-documenting when closure logic grows complex.
- Completion Handlers (R2): `runSimulatedSync(taskName:onComplete:)` accepts a `(Bool, String) -> Void` closure and invokes it once the simulated work finishes.

## Captured State & Lifetime (R4 & R5)

- Value Capture in Counter (`buildStepCounter`): The returned closure captures `runningCount` by reference from its surrounding function scope. Even after `buildStepCounter` finishes executing, `runningCount` stays alive on the heap as long as `nextTicketNumber` exists, incrementing across calls.
- Preventing Retain Cycles (`SyncScheduler`): Because `SyncScheduler` strongly owns `scheduledAction`, capturing `self` strongly inside that closure would create a permanent retain cycle. Using `[weak self]` breaks the strong reference loop so `deinit` executes immediately when `scheduler` is set to `nil`.
