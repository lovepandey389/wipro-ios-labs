import SwiftUI

struct SessionModule: Identifiable, Hashable {
    let id: String
    let title: String
    let instructor: String
    let room: String
    let notes: String
}

@main
struct BasicNavigationApp: App {
    @State private var navigationPath: [SessionModule] = []

    var body: some Scene {
        WindowGroup {
            ModuleDirectoryView(navigationPath: $navigationPath)
                .onOpenURL { incomingURL in
                    handleDeepLink(incomingURL)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "wiproios",
              let targetID = url.host,
              let matched = SessionModule.allItems.first(where: { $0.id.caseInsensitiveCompare(targetID) == .orderedSame }) else {
            return
        }
        navigationPath = [matched]
    }
}

struct ModuleDirectoryView: View {
    @Binding var navigationPath: [SessionModule]
    @State private var modules: [SessionModule] = SessionModule.allItems
    @State private var searchQuery: String = ""

    private var filteredModules: [SessionModule] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return modules }
        return modules.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.id.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(filteredModules) { module in
                NavigationLink(value: module) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(module.title)
                            .font(.headline)
                        Text("\(module.id) • \(module.instructor)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .navigationTitle("Training Modules")
            .searchable(text: $searchQuery, prompt: "Search module title or code")
            .navigationDestination(for: SessionModule.self) { selectedModule in
                ModuleDetailDestinationView(
                    module: selectedModule,
                    onJumpToRoot: {
                        navigationPath.removeAll()
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Deep Link #3") {
                        if let target = modules.last {
                            navigationPath = [target]
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let nextNumber = modules.count + 1
                        let added = SessionModule(
                            id: "MOD-0\(nextNumber)",
                            title: "Bonus Workshop #\(nextNumber)",
                            instructor: "Mr. P. Vishal",
                            room: "Lab B",
                            notes: "Added dynamically via toolbar action."
                        )
                        modules.append(added)
                    } label: {
                        Label("Add Module", systemImage: "plus")
                    }
                }
            }
        }
    }
}

struct ModuleDetailDestinationView: View {
    let module: SessionModule
    let onJumpToRoot: () -> Void

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Code", value: module.id)
                LabeledContent("Instructor", value: module.instructor)
                LabeledContent("Location", value: module.room)
            }

            Section("Session Notes") {
                Text(module.notes)
                    .font(.body)
            }

            Section {
                Button("Return to Directory Root", action: onJumpToRoot)
                    .foregroundStyle(.blue)
            }
        }
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SessionModule {
    static let allItems: [SessionModule] = [
        SessionModule(
            id: "MOD-01",
            title: "SwiftUI App Entry Point",
            instructor: "Mr. P. Vishal",
            room: "Room 201",
            notes: "Covers @main App protocol, Scene lifecycle, and initial WindowGroup setup."
        ),
        SessionModule(
            id: "MOD-02",
            title: "Type-Safe NavigationStack",
            instructor: "Mr. P. Vishal",
            room: "Room 202",
            notes: "Uses NavigationLink(value:) paired with navigationDestination(for:) and a bound path array."
        ),
        SessionModule(
            id: "MOD-03",
            title: "Toolbars & Deep-Link Routes",
            instructor: "Mr. P. Vishal",
            room: "Lab A",
            notes: "Demonstrates toolbar actions, onOpenURL routing, and clean back-stack popping."
        )
    ]
}

#Preview {
    ModuleDirectoryView(navigationPath: .constant([]))
}
