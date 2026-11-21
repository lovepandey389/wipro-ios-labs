import SwiftUI

struct TrackCourse: Identifiable, Hashable {
    let id: String
    let title: String
    let track: String
    let summary: String
}

final class CourseFavoritesStore: ObservableObject {
    @Published private(set) var courses: [TrackCourse] = [
        TrackCourse(
            id: "IOS-811",
            title: "SwiftUI State & Bindings",
            track: "SwiftUI",
            summary: "Understand single source of truth using @State, @Binding, and ObservableObject."
        ),
        TrackCourse(
            id: "IOS-812",
            title: "Data Flow Across Views",
            track: "Architecture",
            summary: "Synchronize list, filter, and detail screens cleanly without duplicate state."
        ),
        TrackCourse(
            id: "IOS-813",
            title: "Local State Persistence",
            track: "Storage",
            summary: "Save user preferences and favourites reliably across app relaunches."
        ),
        TrackCourse(
            id: "IOS-814",
            title: "Swift Concurrency Essentials",
            track: "Concurrency",
            summary: "Coordinate async tasks and MainActor UI updates safely."
        )
    ]

    @Published private(set) var favoriteIDs: Set<String> {
        didSet {
            saveFavoritesToDisk()
        }
    }

    private let storageKey = "lab8c_saved_favorite_ids"

    init() {
        let savedArray = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        self.favoriteIDs = Set(savedArray)
    }

    func isFavorite(_ course: TrackCourse) -> Bool {
        favoriteIDs.contains(course.id)
    }

    func toggleFavorite(for course: TrackCourse) {
        if favoriteIDs.contains(course.id) {
            favoriteIDs.remove(course.id)
        } else {
            favoriteIDs.insert(course.id)
        }
    }

    private func saveFavoritesToDisk() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: storageKey)
    }
}

struct FavoriteStarButton: View {
    @Binding var isStarred: Bool

    var body: some View {
        Button {
            isStarred.toggle()
        } label: {
            Image(systemName: isStarred ? "star.fill" : "star")
                .foregroundStyle(isStarred ? .yellow : .secondary)
                .font(.title3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isStarred ? "Remove from favourites" : "Add to favourites")
    }
}

struct FilterHeaderBar: View {
    @Binding var searchText: String
    @Binding var showOnlyFavorites: Bool

    var body: some View {
        VStack(spacing: 10) {
            TextField("Search courses...", text: $searchText)
                .textFieldStyle(.roundedBorder)

            Toggle("Show Favourites Only", isOn: $showOnlyFavorites)
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct CourseCatalogListView: View {
    @StateObject private var store = CourseFavoritesStore()
    @State private var searchQuery: String = ""
    @State private var favoritesOnlyFilter: Bool = false

    private var matchingCourses: [TrackCourse] {
        store.courses.filter { course in
            let matchesFav = !favoritesOnlyFilter || store.isFavorite(course)
            let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesQuery = trimmed.isEmpty ||
                course.title.localizedCaseInsensitiveContains(trimmed) ||
                course.track.localizedCaseInsensitiveContains(trimmed)
            return matchesFav && matchesQuery
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FilterHeaderBar(
                    searchText: $searchQuery,
                    showOnlyFavorites: $favoritesOnlyFilter
                )

                if matchingCourses.isEmpty {
                    ContentUnavailableView(
                        "No Matching Courses",
                        systemImage: "star.slash",
                        description: Text("Adjust your search or turn off the favourites filter.")
                    )
                } else {
                    List(matchingCourses) { course in
                        HStack {
                            NavigationLink(destination: CourseDetailSyncView(course: course, store: store)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(course.title)
                                        .font(.headline)
                                    Text("\(course.id) • \(course.track)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            FavoriteStarButton(
                                isStarred: Binding(
                                    get: { store.isFavorite(course) },
                                    set: { _ in store.toggleFavorite(for: course) }
                                )
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Courses (\(store.favoriteIDs.count) ★)")
        }
    }
}

struct CourseDetailSyncView: View {
    let course: TrackCourse
    @ObservedObject var store: CourseFavoritesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(course.track.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())

                Spacer()

                FavoriteStarButton(
                    isStarred: Binding(
                        get: { store.isFavorite(course) },
                        set: { _ in store.toggleFavorite(for: course) }
                    )
                )
            }

            Text(course.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(course.summary)
                .font(.body)
                .foregroundStyle(.secondary)

            Button {
                store.toggleFavorite(for: course)
            } label: {
                Label(
                    store.isFavorite(course) ? "Saved in Favourites" : "Mark as Favourite",
                    systemImage: store.isFavorite(course) ? "star.fill" : "star"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(20)
        .navigationTitle(course.id)
        .navigationBarTitleDisplayMode(.inline)
    }
}

@main
struct Lab8CStateManagementApp: App {
    var body: some Scene {
        WindowGroup {
            CourseCatalogListView()
        }
    }
}
