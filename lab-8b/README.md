# Lab 8B: Navigation and Basic Template

## How the `@main App` Entry Point Differs from an Individual `View` (R1 & R5)

| Aspect | `@main App` Entry Point (`BasicNavigationApp`) | Individual `View` (`ModuleDirectoryView` / `ModuleDetailDestinationView`) |
| :--- | :--- | :--- |
| Protocol & Return Type | Conforms to `App`; its `body` returns one or more `Scene` containers (such as `WindowGroup`). | Conforms to `View`; its `body` returns UI elements (`some View`) rendered inside a scene. |
| Role & Lifetime | Application root: launches once at process startup (`@main`), manages app-wide scenes, system URLs (`onOpenURL`), and `scenePhase`. | UI building block: lightweight value struct instantiated and re-evaluated whenever its state or bindings change. |
| Navigation Ownership | Hosts the root `WindowGroup` and top-level navigation state (`navigationPath`). | Participates inside a `NavigationStack` by pushing destinations (`NavigationLink`) or popping back. |

## Navigation & Toolbar Behaviour (R2, R3, R4, Extension)

- List-to-Detail Passing: Selecting a row in `ModuleDirectoryView` triggers `NavigationLink(value: module)`, passing the selected `SessionModule` value directly to `navigationDestination(for: SessionModule.self)` and rendering `ModuleDetailDestinationView`.
- Back Navigation: Tapping the system Back button in the navigation bar—or tapping "Return to Directory Root" (`navigationPath.removeAll()`)—cleanly pops the detail view off `navigationPath` and returns to `ModuleDirectoryView`.
- Toolbar & Deep-Link Extension: The trailing `+` toolbar button appends a new `SessionModule` to the list; the leading `Deep Link #3` button (and `onOpenURL` handler for `wiproios://MOD-03`) programmatically pushes `MOD-03` onto `navigationPath` with working back navigation.
