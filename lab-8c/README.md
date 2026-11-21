# Lab 8C: State Management

## State Wrappers Used in This Project

1. `@State` (`searchQuery`, `favoritesOnlyFilter` in `CourseCatalogListView`):
   - Owns private, ephemeral UI state belonging exclusively to the list screen's filter controls. SwiftUI manages its storage across view re-evaluations.
2. `@Binding` (`searchText`, `showOnlyFavorites` in `FilterHeaderBar`, and `isStarred` in `FavoriteStarButton`):
   - Creates a two-way read/write reference to state owned by a parent view or shared store without duplicating data. Child views mutate the parent's source of truth directly.
3. `@StateObject` (`store` in `CourseCatalogListView`):
   - Instantiates and owns the lifecycle of `CourseFavoritesStore` once at the root view so shared course and favourite data survives view redraws.
4. `@ObservedObject` (`store` in `CourseDetailSyncView`) & `@Published` (`courses`, `favoriteIDs`):
   - Subscribes the detail screen to the existing `CourseFavoritesStore` instance. Toggling a favourite in either `CourseCatalogListView` or `CourseDetailSyncView` updates `favoriteIDs` immediately and keeps both screens synchronized.

## When State Should Remain Local vs. Be Shared (R5)

- Keep State Local (`@State` + `@Binding`): When the data is transient UI state relevant only to one screen hierarchy—such as the current search bar text (`searchQuery`) or the "Show Favourites Only" toggle (`favoritesOnlyFilter`). Sharing transient filter state globally adds unnecessary coupling.
- Share State via an Observable Model (`@StateObject` / `@ObservedObject`): When multiple screens need to read and mutate the same domain data—such as `favoriteIDs`, which must stay synchronized across the list rows, navigation bar counter, detail screen button, and `UserDefaults` persistence layer.
