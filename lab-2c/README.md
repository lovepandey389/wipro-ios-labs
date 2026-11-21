# Lab 2C: Protocols, Extensions, and Generics

## Valid vs. Invalid Generic Constraint Usage (R4)

- Valid Use: `formatAllItems<Item: Displayable>(_ items: [Item])` accepts `[Student]` and `[Course]` because both types conform to `Displayable` and implement `renderLine()`.
- Invalid Use: Calling `formatAllItems([UnformattedNote(body: "Draft")])` produces a compile-time error (`Type 'UnformattedNote' does not conform to protocol 'Displayable'`), catching type mismatches before runtime.

## Why Extensions Cannot Replace a New Type for Stored State (R5)

Swift extensions can add computed properties, methods, initializers, and protocol conformances to an existing type, but they cannot add stored properties (`var` or `let` backed by new memory slots) or property observers to existing stored properties. Because adding stored fields would change the memory layout and size of a type across modules, any feature requiring new stored state—such as `Stack<T>` holding `private var storage: [T]`—must be defined as a new `struct`, `class`, or `enum`.
