# Lab 3: Compare UIKit and SwiftUI

## Framework Comparison Table (R4)

| Dimension | UIKit (Imperative) | SwiftUI (Declarative) |
| :--- | :--- | :--- |
| Amount of Code | Higher boilerplate (~75 lines): requires manual view instantiation, translatesAutoresizingMaskIntoConstraints, and NSLayoutConstraint setup. | Concise (~40 lines): views, modifiers, and layout stacks are declared inline. |
| State Updates | Manual mutation inside target-action callbacks (`outcomeLabel.text = ...`); UI and state can drift out of sync if forgotten. | Automatic via `@State` and `$` bindings; mutating state automatically re-renders affected views. |
| Layout Approach | Auto Layout constraints, UIStackView, or frame calculations managed explicitly in code or Storyboards. | Declarative layout containers (`VStack`, `HStack`, `ZStack`) and view modifiers. |
| Previews | Requires running the full iOS Simulator (or wrapping inside a SwiftUI Preview provider). | Instant live interactive previews directly inside Xcode Canvas via `#Preview`. |
| Interoperability | Embeds SwiftUI screens cleanly using `UIHostingController`. | Embeds UIKit views and controllers via `UIViewRepresentable` and `UIViewControllerRepresentable`. |

## Team Adoption Recommendation (R5)

- Choose SwiftUI when starting new iOS 16+ greenfield applications, building rapid prototypes, or developing data-driven screens where reactive state management (`@State`, `@Observable`) accelerates delivery.
- Choose UIKit (or a hybrid UIKit + SwiftUI architecture) when supporting older iOS versions, maintaining large legacy codebases, or implementing highly customized navigation transitions, complex collection layouts, and low-level gesture/animation control not yet exposed in SwiftUI.
