# Lab 7B: Storyboards, View Hierarchy, and Navigation

## Navigation Flow Diagram (R2 & R3)

[UINavigationController (Root)]
        |
        v  (Initial Root Controller)
[TopicListViewController]
        |
        |  1. User taps row at `indexPath`
        |  2. `let chosenTopic = topics[indexPath.row]`
        |  3. `TopicDetailViewController(topic: chosenTopic)` (Initializer Injection - No Globals)
        |  4. `navigationController?.pushViewController(detailController, animated: true)`
        v
[TopicDetailViewController]
        |
        |  User taps Back button -> `popViewController(animated: true)`
        v
[TopicListViewController]

## Xcode View Hierarchy Inspection (R4)

Inspecting the running app via Xcode Debug View Hierarchy shows the following parent-child tree:

- List Screen:
  UIWindow
   └── UITransitionView
        └── UIDropShadowView
             └── UILayoutContainerView (UINavigationController)
                  ├── UINavigationTransitionView
                  │    └── UIViewControllerWrapperView
                  │         └── UIView (TopicListViewController.view)
                  │              └── UITableView
                  │                   └── ModuleCatalogCell
                  │                        └── UITableViewCellContentView
                  │                             └── UIStackView
                  │                                  ├── UILabel (titleLabel)
                  │                                  └── UILabel (subtitleLabel)
                  └── UINavigationBar

- Detail Screen:
  UIView (TopicDetailViewController.view)
   └── UIStackView
        ├── UILabel (codeBadgeLabel)
        ├── UILabel (headingLabel)
        ├── UILabel (durationLabel)
        └── UILabel (summaryLabel)

## Safe Setup Without Force-Unwrapped Outlets (R5)

- All views and subviews are instantiated programmatically with explicit types rather than implicitly unwrapped `@IBOutlet!` properties, eliminating `Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value` crashes.
- `TopicDetailViewController` requires `init(topic: TrainingTopic)` so the screen cannot be constructed in an incomplete state without its model data, and cell dequeuing uses a safe `guard let cell = ... as? ModuleCatalogCell` fallback.
