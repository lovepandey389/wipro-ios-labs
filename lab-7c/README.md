# Lab 7C: UI Controls and View Lifecycle

## Controls Wired to Summary Panel (R1 & R2)

Five UIKit controls (`UITextField`, `UISegmentedControl`, `UISwitch`, `UISlider`, and `UIButton`) are connected via `addTarget(_:action:for:)` to `refreshSummaryPanel()`, dynamically updating the live summary card on every edit, toggle, slide, or segment selection.

## Recorded Lifecycle Log During Push & Pop Navigation (R3)

[21:14:01.102] Screen 1 (Controls): viewDidLoad
[21:14:01.108] Screen 1 (Controls): viewWillAppear (#1)
[21:14:01.340] Screen 1 (Controls): viewDidAppear
[21:14:06.812] Screen 1 (Controls): viewWillDisappear
[21:14:06.815] Screen 2 (Report): viewDidLoad
[21:14:06.817] Screen 2 (Report): viewWillAppear
[21:14:07.180] Screen 1 (Controls): viewDidDisappear
[21:14:07.181] Screen 2 (Report): viewDidAppear
[21:14:11.404] Screen 2 (Report): viewWillDisappear
[21:14:11.406] Screen 1 (Controls): viewWillAppear (#2)
[21:14:11.760] Screen 2 (Report): viewDidDisappear
[21:14:11.761] Screen 1 (Controls): viewDidAppear

## Setup in `viewDidLoad` vs. Refresh in `viewWillAppear` (R4)

- `viewDidLoad` (Runs once when the view hierarchy loads into memory): Best for one-time structural work—constructing subviews, activating Auto Layout constraints, attaching `addTarget` handlers, and assigning delegates.
- `viewWillAppear` (Runs every time the view is about to become visible again, including when popping back from Screen 2): Best for refreshing dynamic UI values, updating visit counters (`appearanceCount`), and reloading data that may have changed while the screen was off-screen.

## Keyboard Layout Verification & Accessibility Audit (R5 & Extension)

- Keyboard Presentation & Dismissal: Pinning `scrollView.bottomAnchor` to `view.keyboardLayoutGuide.topAnchor` automatically shrinks the scrollable viewport when the software keyboard rises, keeping the summary card and action button reachable, and restores full height cleanly upon tapping Return or tapping outside (`view.endEditing(true)`).
- Accessibility & Contrast Fixes: Added explicit `accessibilityLabel` descriptions to every interactive control (`UITextField`, `UISegmentedControl`, `UISwitch`, `UISlider`, `UIButton`) and replaced hardcoded gray text with high-contrast semantic colors (`.label` on `.secondarySystemBackground` and `.systemBackground`).
