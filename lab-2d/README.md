# Lab 2D: Error Handling

## Success and Failure Test Cases

| Case | Roll ID | Name | Mark | Outcome | Message Shown |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Valid Registration | W-1042 | Love Pandey | 91.5 | Success | Enrolled: Love Pandey [W-1042] - Score: 91.5 |
| Blank Name | W-1043 | "   " | 85.0 | Failure (emptyName) | Registration rejected: Student name cannot be blank. |
| Malformed ID | 1044 | Riya Sen | 88.0 | Failure (invalidID) | Registration rejected: '1044' must follow format W-XXXX. |
| Out-of-Range Mark | W-1045 | Kabir Das | 112.0 | Failure (invalidMark) | Registration rejected: Score 112.0 must be between 0 and 100. |
| Simulated API Error | - | - | - | Failure (badServerCode 503) | Server is temporarily unavailable (Error 503). Try again shortly. |

## Comparison: throws vs. Optional Return vs. Result (R4)

- Optional Return (`Int?`): Best when a failure has only one obvious meaning (such as failing to parse a number) and the caller does not need to know why it failed.
- Throwing Function (`throws`): Ideal for synchronous multi-step validation like `enrollLearner`, where callers must handle distinct error reasons via `do`/`catch` and propagate failures cleanly.
- `Result<Success, Failure>`: Best when storing an outcome for later inspection, chaining transformations (`map`/`mapError`), or passing typed success/failure values across asynchronous completion handlers.
