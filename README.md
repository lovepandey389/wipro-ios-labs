# Lab 1A: Test Cases & Variable Rationale

## Variable Mutability (`let` vs `var`)
- **`let` (Constants):** Used for values that stay fixed during execution (`fullMarksPerPaper`, `minimumSubjectPass`, `requiredAttendance`, `appliedCredit`, `awardedGrade`).
- **`var` (Variables):** Used for values that change or accumulate during calculation (`aggregateMarks`, `clearedAllPapers`, `meanScore`, `overallPercentage`, `finalPassStatus`).

## 8 Input / Output Test Cases

| Test Case | Candidate | Input Scores (5 Papers) | Attendance | Extra Credit / Note | Expected Output & Grade |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC1** | Devansh Kulkarni (`WIP-201`) | `94, 91, 97, 93, 96` | `96.0%` | `nil` / `nil` | **PASSED** — Aggregate: `471.0/500`, Mean: `94.20`, Percentage: `94.20%`, Grade: `O` |
| **TC2** | Sneha Iyer (`WIP-202`) | `64, 71, 69, 73, 62` | `84.0%` | `4.0` / `"Steady progress"` | **PASSED** — Aggregate: `343.0/500`, Mean: `68.60`, Percentage: `68.60%`, Grade: `B` |
| **TC3** | Karan Malhotra (`WIP-203`) | `100, 100, 100, 100, 100` | `100.0%` | `nil` / `"Top scorer"` | **PASSED** — Aggregate: `500.0/500`, Mean: `100.00`, Percentage: `100.00%`, Grade: `O` |
| **TC4** | Pooja Joshi (`WIP-204`) | `0, 0, 0, 0, 0` | `80.0%` | `nil` / `nil` | **FAILED** — Aggregate: `0.0/500`, Mean: `0.00`, Percentage: `0.00%`, Grade: `F` |
| **TC5** | Harshvardhan Rao (`WIP-205`) | `82, 79, 31, 76, 88` | `91.0%` | `nil` / `"Retake required..."` | **FAILED** — Paper 3 score (`31`) is below `40.0`, Grade: `F` |
| **TC6** | Nandini Menon (`WIP-206`) | `81, 86, 84, 79, 89` | `68.0%` | `nil` / `"Low attendance"` | **FAILED** — Attendance (`68.0%`) is below `75.0%`, Grade: `F` |
| **TC7** | Siddharth Bose (`WIP-207`) | `104, 80, -3, 72, 85` | `88.0%` | `nil` / `nil` | **Error:** Score `104.0` is outside valid range (`0-100`). |
| **TC8** | Tanya Chawla (`WIP-208`) | `76, 81, 79, 83, 80` | `108.0%` | `nil` / `nil` | **Error:** Attendance `108.0%` is outside valid range (`0-100`). |
