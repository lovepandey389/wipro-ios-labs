# Lab 4B: App, Scene, and View Lifecycles

## Recorded Event Log (R1, R2, R3)

[19:10:02.114] Root View: onAppear (Restored draft)
[19:10:02.118] Screen 1 (Dashboard): onAppear (#1)
[19:10:02.119] Screen 1: Lightweight timestamp refresh executed
[19:10:02.145] ScenePhase: inactive -> active
[19:10:08.402] Screen 2 (Detail): onAppear
[19:10:08.910] Screen 1 (Dashboard): onDisappear
[19:10:12.305] Screen 2 (Detail): onDisappear
[19:10:12.308] Screen 1 (Dashboard): onAppear (#2)
[19:10:12.309] Screen 1: Lightweight timestamp refresh executed
[19:10:18.012] ScenePhase: active -> inactive
[19:10:18.640] ScenePhase: inactive -> background (Saved draft)

## Lightweight Refresh Placement & Justification (R4)

- Choice: Placed `performLightweightRefresh()` inside Screen 1's `onAppear` modifier (rather than `init()` or `scenePhase == .background`).
- Justification: In SwiftUI, a view's `init()` can run multiple times whenever a parent view re-evaluates its body, making `init()` unsuitable for side effects. `onAppear` runs deterministically each time the screen enters the visible viewport—both on initial launch and whenever the user navigates back from Screen 2—ensuring displayed timestamps/summaries stay up to date without blocking app launch or running while off-screen.

## Repeated Appearance Behaviour (R5)

- As shown in the event log (`onAppear (#1)` on launch and `onAppear (#2)` after popping Screen 2), `onAppear` fires every time a view becomes visible again—not once per app lifetime.
- Therefore, one-time setup or accumulative mutations (such as appending duplicate items or registering duplicate observers) must be guarded or kept idempotent so returning to Screen 1 does not corrupt state.
