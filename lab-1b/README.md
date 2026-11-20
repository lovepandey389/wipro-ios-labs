# Lab 1B — Access Control & Encapsulation

## Access Level Visibility Across Files

| Modifier | Visibility Rule | Used On | Visible in `BankAccount.swift`? | Visible in `main.swift`? |
| :--- | :--- | :--- | :--- | :--- |
| `private` | Only inside the enclosing `BankAccount` class. | `currentBalance`, `evaluateThreshold(_:)` | Yes (inside class only) | No |
| `fileprivate` | Anywhere inside `BankAccount.swift`. | `highActivityAlert` | Yes (including `BranchCompliance`) | No |
| `internal` | Anywhere inside the same Swift module/app. | `branchCode` | Yes | Yes |
| `public` | Accessible inside the module and by external callers. | `BankAccount`, `deposit(_:)`, `withdraw(_:)` | Yes | Yes |
| `public private(set)` | Readable everywhere, writable only inside `BankAccount`. | `activityLog` | Read & Write | Read-only |

## Key Encapsulation Choices
- **Safe State Mutation:** `currentBalance` is `private`, forcing all balance changes through `deposit(_:)` and `withdraw(_:)`.
- **Validation:** Negative/zero transactions, overdrafts, and invalid initial balances are rejected before state changes occur.
