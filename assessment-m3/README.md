# Milestone 3: Networking and UIKit

## R5: Viva Quick-Reference Notes

1. View Hierarchy:
   - Every `UIViewController` manages a root `view` (`UIView`) inside a `UIWindow` and `UINavigationController` container.
   - Subviews form a tree (`view -> formStack / tableView -> UITableViewCell -> contentView`), where parent views clip and position child views and forward touch events through the responder chain.

2. Auto Layout Constraints:
   - Constraints define mathematical relationships (`NSLayoutConstraint`) between view attributes (top, leading, trailing, bottom, width, height) relative to `safeAreaLayoutGuide` or sibling views.
   - Setting `translatesAutoresizingMaskIntoConstraints = false` disables legacy autoresizing masks so views adapt cleanly across compact and large iPhone screen sizes without fixed coordinates.

3. `URLSession`:
   - `URLSession.shared.data(for: request)` executes asynchronous HTTP requests off the main thread and returns `(Data, URLResponse)`.
   - Inspecting `HTTPURLResponse.statusCode` (validating `200...299`) ensures HTTP errors are caught before attempting JSON parsing.

4. `Codable`:
   - `Codable` (`Encodable & Decodable`) synthesizes type-safe serialization between Swift structs (`RemotePost`) and external formats like JSON via `JSONDecoder`.
   - Mismatched keys or types throw `DecodingError`, preventing silent runtime crashes from malformed API payloads.
