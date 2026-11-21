# Milestone 1: Swift Foundations

## R3: Retain Cycle Fix Explanation

- Object-to-Object Cycle: MentorProfile holds a strong reference to CapstoneTeam via `activeProject`, while CapstoneTeam declares `weak var mentor: MentorProfile?`. Making the back-reference `weak` breaks the strong ownership loop because a team can exist independently of its mentor, allowing both `deinit` methods to execute when external references become `nil`.
- Closure Capture Cycle: CapstoneTeam stores an escaping closure (`onStatusUpdate`) that references `self`. Adding `[weak self]` to the capture list prevents the closure from retaining `CapstoneTeam`, avoiding a memory leak.

## R5: Viva Quick-Reference Notes

1. struct vs. class:
   - `struct` is a value type: copying creates an independent instance, supports automatic memberwise initializers, has no inheritance, and avoids ARC reference-counting overhead.
   - `class` is a reference type: variables share a pointer to the same instance, supports class inheritance, has `deinit`, and is managed by Automatic Reference Counting (ARC).

2. protocol vs. inheritance:
   - Inheritance allows a class to inherit implementation from only one superclass (single inheritance), creating tight coupling.
   - Protocols define a blueprint of methods and properties that structs, classes, and enums can all adopt (multiple conformances), enabling decoupled protocol-oriented design and default behavior via protocol extensions.

3. map, filter, and reduce:
   - `map`: Transforms every element in a collection into a new array of the same length (e.g., `[GradeRecord] -> [String]`).
   - `filter`: Selects elements matching a boolean condition into a subset array.
   - `reduce`: Combines all elements of a collection into a single accumulated value (such as summing an array of marks).
