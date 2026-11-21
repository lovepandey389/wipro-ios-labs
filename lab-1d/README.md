# Lab 1D: Optionals and Safe Unwrapping

## Techniques Implemented

- **`if let`**: Safely checks whether `findScore(byRollCode:)` returns a `Double` or `nil`, printing the score when present and a fallback message when a dictionary key is missing.
- **`guard let`**: Validates optional text-field input at the start of `validateSearchInput(_:)` and exits early if the string is `nil` or contains only whitespace.
- **Optional Chaining (`?.`)**: Accesses `student?.homeAddress?.capitalized` without risking a runtime crash if either the `StudentProfile` instance or `homeAddress` is `nil`.
- **Nil-Coalescing (`??`)**: Supplies a default `0.0` score in `computeAdjustedMarks(rollCode:)` and default label text when optional properties are absent.

## Force-Unwrap Check

No `!` operators appear anywhere in `lab-1d/`, guaranteeing safe execution across missing keys and empty inputs.
