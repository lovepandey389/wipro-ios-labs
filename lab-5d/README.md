# Lab 5D: Concurrency Safety

## Before vs. After Observation (R1 & R2)

- Before (`UnsafeHitCounter`): Multiple child tasks inside `withTaskGroup` read and write `totalHits` simultaneously without synchronization. Because `totalHits = current + 1` is non-atomic, concurrent tasks overwrite each other's updates (a data race), producing lost increments (e.g., observing ~1,840 instead of 2,000).
- After (`SafeHitCounter` actor): Replacing the plain class with a Swift `actor` isolates `totalHits` so only one task accesses its mutable state at a time. Callers interact via `await counter.recordHit()`, guaranteeing 2,000 out of 2,000 updates across every stress-test round.

## Beginner Explanation of `Sendable` (R3)

- `Sendable` is a Swift marker protocol indicating that a type's values can be safely passed across concurrency boundaries (such as into a `Task` or between actors) without risking data races.
- Value types composed of immutable or thread-safe properties—like `struct HitEvent: Sendable`—automatically conform to `Sendable` because each task receives an independent copy.
- Plain classes with mutable `var` properties are not `Sendable` because sharing the same reference across threads allows simultaneous unsynchronized writes; isolating mutable state inside an `actor` solves this safely.

## Compiler Warnings & Diagnostics Documented (R4)

- Under Swift strict concurrency checking (`-strict-concurrency=complete`), passing a non-`Sendable` mutable class (`UnsafeHitCounter`) into a `@Sendable` `group.addTask` closure triggers a compiler warning/error: `Capture of 'unsafeCounter' with non-Sendable type 'UnsafeHitCounter' in a @Sendable closure`.
- In our Before sample, `@unchecked Sendable` is used strictly to compile and demonstrate the runtime data race; in the production After solution (`SafeHitCounter` actor and `HitEvent` struct), zero `@unchecked Sendable` overrides or compiler warnings remain.
