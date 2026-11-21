# Lab 7A: UIKit Profile Form

## Validation Test Cases

| Test Case | Name Input | Email Input | Course Input | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1. All Fields Empty / Too Short | `"A"` | `"bad-email"` | `"   "` | All 3 inline red error labels appear; form does not submit | Passed |
| 2. Malformed Email Domain | `"Love Pandey"` | `"love@.com"` | `"iOS"` | Inline email error shown; name and course errors hidden | Passed |
| 3. Blank Course Title | `"Love Pandey"` | `"love@example.com"` | `""` | Inline course error shown; submission blocked | Passed |
| 4. Valid Input with Whitespace | `"  Love Pandey  "` | `"love@example.com"` | `"iOS Swift"` | Trims spaces, hides all error labels, displays green confirmation banner | Passed |

## Keyboard, Accessibility & Responsive Layout Notes (R2, R4, R5, Extension)

- Auto Layout & Keyboard Avoidance: Uses `UIScrollView` pinned to `safeAreaLayoutGuide` and `keyboardLayoutGuide` with zero hardcoded frame coordinates, preventing keyboard overlap on compact screens.
- Keyboard & Accessibility Configuration: Email uses `.emailAddress` keyboard and `.emailAddress` content type with autocorrection disabled; Next/Done return keys advance focus cleanly; tapping outside dismisses the keyboard; every input and button defines an explicit `accessibilityLabel`.
- Simulator Sizes Tested (Portrait): Verified on compact screen (`iPhone SE (3rd generation)`) and large screen (`iPhone 16 Pro Max`), plus Dynamic Type Extra Large text and Dark Mode semantic colors (`systemBackground`, `systemRed`, `systemGreen`).
