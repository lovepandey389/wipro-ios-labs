# Lab 5A: GCD, Queues, and Main-Thread UI

## Recorded Queue & Thread Event Log (R5)

[MAIN THREAD | com.apple.main-thread] viewDidLoad initialized
[MAIN THREAD | com.apple.main-thread] 1. Button tapped & UI locked
[BACKGROUND THREAD | com.apple.root.user-initiated-qos] 2. Started slow computation on global queue
[BACKGROUND THREAD | com.apple.root.user-initiated-qos] 3. Delayed network response arrived via asyncAfter
[MAIN THREAD | com.apple.main-thread] 4. Restoring UI on DispatchQueue.main

## Why the UI Must Not Be Updated from a Background Queue

1. UIKit Is Not Thread-Safe: UIKit classes (`UIView`, `UILabel`, `UIButton`, `UIActivityIndicatorView`) mutate shared layout geometry, layer trees, and responder state without internal locks. Modifying UI properties from a background queue causes race conditions, visual corruption, dropped frames, or delayed rendering until the next Core Animation commit cycle.
2. Runtime Crashes & Main Thread Checker Violations: Xcode's Main Thread Checker immediately flags off-main-thread UI mutations because Core Animation and UIKit's run loop expect all layout, drawing, and touch-handling events to execute serially on `DispatchQueue.main`.
3. Preventing Unresponsive UI & Duplicate Submissions: Running heavy work (`Thread.sleep`, large loops, network waits) on `DispatchQueue.global` keeps the main run loop free to animate the `UIActivityIndicatorView` smoothly, while disabling buttons until `DispatchQueue.main.async` runs prevents duplicate requests.
