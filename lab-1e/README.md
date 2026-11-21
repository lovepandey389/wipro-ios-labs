cat << 'EOF' > lab-1e/README.md
# Lab 1E: Classes, Structs, ARC, and Memory

## Value vs. Reference Behaviour Observed (R2)

- **Struct (`ModuleBlueprint`)**: Assigning `originalModule` to `copiedModule` created an independent copy. Changing `copiedModule.title` left `originalModule.title` unchanged.
- **Class (`CohortCoordinator`)**: Assigning `leadCoordinator` to `sharedCoordinator` copied the reference pointing to the same underlying instance. Updating `sharedCoordinator.activeSection` simultaneously changed `leadCoordinator.activeSection`.

## Preventing Strong Reference Cycles (R3 & R4)

- **Object Relationship (`Mentor` and `LectureHall`)**: `Mentor` holds a strong reference to `LectureHall`, while `LectureHall` declares `weak var primaryMentor: Mentor?`. Because a room can exist without an assigned mentor, `weak` breaks the ownership cycle and allows both `deinit` blocks to execute when references are set to `nil`.
- **Closure Capture (`SessionTracker`)**: Storing a closure on `self` that references `self` normally creates a retain cycle. Adding `[weak self]` to the capture list prevents the closure from incrementing the reference count, ensuring `SessionTracker` deallocates cleanly.

## Value/Reference Semantics & Memory Storage (R5)

Value semantics guarantee independent state on assignment and mutation, whereas reference semantics share mutable state across references. Rather than assuming all value types always live on the stack, Swift decides memory placement dynamically: value types stored inside class properties, captured by escaping closures, or exceeding inline buffer limits are allocated on the heap, while Copy-on-Write collections (`Array`, `Dictionary`, `String`) store their underlying elements in shared heap buffers until mutated.
EOF
