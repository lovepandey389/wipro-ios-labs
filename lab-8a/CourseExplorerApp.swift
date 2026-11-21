import SwiftUI

struct ExplorerCourse: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let statusText: String
    let durationHours: Int
    let overview: String
}

struct CategoryBadgeView: View {
    let categoryName: String

    var body: some View {
        Text(categoryName.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.15))
            .foregroundStyle(Color.accentColor)
            .clipShape(Capsule())
    }
}

struct StatusPillView: View {
    let status: String

    private var badgeColor: Color {
        switch status {
        case "Completed":
            return .green
        case "In Progress":
            return .orange
        default:
            return .blue
        }
    }

    var body: some View {
        Text(status)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.16))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }
}

struct CourseSummaryCard: View {
    let title: String
    let subtitle: String
    let category: String
    let status: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    CategoryBadgeView(categoryName: category)
                    Spacer()
                    StatusPillView(status: status)
                }

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(14)
        }
    }
}

struct EmptyCoursesPlaceholderView: View {
    let onReload: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "books.vertical")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("No Courses Found")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Your catalog is currently empty. Restore sample courses to continue exploring.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Button("Restore Sample Courses", action: onReload)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CourseDetailScreen: View {
    let course: ExplorerCourse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.14))
                        .frame(height: 130)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            CategoryBadgeView(categoryName: course.category)
                            StatusPillView(status: course.statusText)
                        }
                        Text(course.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(16)
                }

                Text(course.subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Divider()

                HStack {
                    Label("\(course.durationHours) Hours", systemImage: "clock")
                    Spacer()
                    Label(course.id, systemImage: "number")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text("Course Overview")
                    .font(.headline)

                Text(course.overview)
                    .font(.body)
                    .lineSpacing(4)
            }
            .padding(16)
        }
        .navigationTitle(course.id)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CourseExplorerHomeView: View {
    @State private var courses: [ExplorerCourse] = ExplorerCourse.sampleCatalog
    @State private var selectedCategory: String = "All"

    private let categories = ["All", "Swift", "UIKit", "SwiftUI", "Concurrency"]

    private var visibleCourses: [ExplorerCourse] {
        guard selectedCategory != "All" else { return courses }
        return courses.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilterBar

                if visibleCourses.isEmpty {
                    EmptyCoursesPlaceholderView {
                        courses = ExplorerCourse.sampleCatalog
                        selectedCategory = "All"
                    }
                } else {
                    List(visibleCourses) { course in
                        NavigationLink(destination: CourseDetailScreen(course: course)) {
                            CourseSummaryCard(
                                title: course.title,
                                subtitle: course.subtitle,
                                category: course.category,
                                status: course.statusText
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Course Explorer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(courses.isEmpty ? "Load" : "Clear") {
                        courses = courses.isEmpty ? ExplorerCourse.sampleCatalog : []
                    }
                }
            }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedCategory == category ? Color.accentColor : Color(.secondarySystemBackground))
                            .foregroundStyle(selectedCategory == category ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

extension ExplorerCourse {
    static let sampleCatalog: [ExplorerCourse] = [
        ExplorerCourse(
            id: "IOS-801",
            title: "SwiftUI App Structure & Views",
            subtitle: "Compose declarative screens using VStack, HStack, ZStack, and extracted subviews.",
            category: "SwiftUI",
            statusText: "In Progress",
            durationHours: 5,
            overview: "Learn how to break complex SwiftUI interfaces into small, composable view structs with clean state boundaries and fast Xcode Previews."
        ),
        ExplorerCourse(
            id: "IOS-802",
            title: "Structured Concurrency in Practice",
            subtitle: "Coordinate parallel async tasks safely with TaskGroup and MainActor.",
            category: "Concurrency",
            statusText: "Completed",
            durationHours: 6,
            overview: "Build responsive iOS apps using async/await, cooperative cancellation, and actor-isolated shared state."
        ),
        ExplorerCourse(
            id: "IOS-803",
            title: "UIKit Programmatic Auto Layout",
            subtitle: "Master UINavigationController stacks, custom cells, and keyboard layout guides.",
            category: "UIKit",
            statusText: "Completed",
            durationHours: 7,
            overview: "Construct adaptive UIKit screens without fixed coordinates or force-unwrapped outlets."
        ),
        ExplorerCourse(
            id: "IOS-804",
            title: "Protocol-Oriented Swift Design",
            subtitle: "Write flexible, testable abstractions with protocols, extensions, and generics.",
            category: "Swift",
            statusText: "Upcoming",
            durationHours: 4,
            overview: "Design decoupled domain models and generic data structures with compile-time type safety."
        )
    ]
}

#Preview("Course Explorer - Populated") {
    CourseExplorerHomeView()
}

#Preview("Course Card Component") {
    CourseSummaryCard(
        title: "SwiftUI App Structure",
        subtitle: "Composable layout containers and extracted subviews.",
        category: "SwiftUI",
        status: "In Progress"
    )
    .padding()
}
