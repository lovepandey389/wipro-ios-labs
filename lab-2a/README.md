mkdir -p lab-2a && cat << 'EOF' > lab-2a/README.md
# Lab 2A: Functions and Higher-Order Functions

## Test Cases Table

| Function | Sample Input | Expected Output | Actual Output |
| :--- | :--- | :--- | :--- |
| computeAverage(of:) | [72.5, 88.0, 94.5, 81.0] | 84.0 | 84.0 |
| findHighestValue(in:) | [72.5, 88.0, 94.5, 81.0] | 94.5 | 94.5 |
| isValidEmailFormat(_:) | "love.pandey@example.com" | true | true |
| isValidEmailFormat(_:) | "invalid-email@" | false | false |
| formatDisplayName(firstName:lastName:) | "  love ", " pandey " | "Love Pandey" | "Love Pandey" |
| totalExpensesFunctional(from:) | 4 ledger entries (3 expenses) | 2900.0 | 2900.0 |
| rankLearners(_:) | Rohan (88), Ananya (95), Dev (88), Kabir (79) | Ananya, Dev, Rohan, Kabir | Ananya, Dev, Rohan, Kabir |

## Loop-Based vs. Higher-Order Function Comparison (R4)

Chaining filter, map, and reduce expresses what transformation is happening to the data pipeline in a declarative, concise style without managing mutable accumulator variables (var runningTotal = 0.0). However, a traditional for-in loop avoids allocating intermediate arrays between filter and map, allows early exits (break/continue), and is often easier to step through in a debugger when inspecting individual iterations.
EOF
