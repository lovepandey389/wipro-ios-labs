import SwiftUI
import Combine

struct MilestoneTask: Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var category: String
    var isDone: Bool

    init(id: UUID = UUID(), title: String, category: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.isDone = isDone
    }
}

enum SyncPhase: Equatable {
    case idle
    case loading
    case success
    case error(String)
    case cancelled
}

enum DataSyncError: LocalizedError {
    case simulatedFailure

    var errorDescription: String? {
        return "Remote sync failed. Check connection and retry."
    }
}

struct RemoteWorkspaceService: Sendable {
    func fetchSprintTasks(shouldFail: Bool) async throws -> [MilestoneTask] {
        try await Task.sleep(nanoseconds: 700_000_000)
        try Task.checkCancellation()
        if shouldFail {
            throw DataSyncError.simulatedFailure
        }
        return [
            MilestoneTask(title: "Review MVVM Bindings", category: "Sprint"),
            MilestoneTask(title: "Verify MainActor Isolation", category: "Sprint")
        ]
    }

    func fetchBacklogTasks(shouldFail: Bool) async throws -> [MilestoneTask] {
        try await Task.sleep(nanoseconds: 900_000_000)
        try Task.checkCancellation()
        if shouldFail {
            throw DataSyncError.simulatedFailure
        }
        return [
            MilestoneTask(title: "Prepare Concurrency Viva Notes", category: "Backlog"),
            MilestoneTask(title: "Benchmark TaskGroup Speedup", category: "Backlog")
        ]
    }
}

@MainActor
final class MilestoneTaskViewModel: ObservableObject {
    @Published private(set) var items: [MilestoneTask] = []
    @Published private(set) var syncPhase: SyncPhase = .idle
    @Published var newTitle: String = ""
    @Published var simulateFailure: Bool = false

    private let service: RemoteWorkspaceService
    private var syncJob: Task<Void, Never>?

    init(service: RemoteWorkspaceService = RemoteWorkspaceService()) {
        self.service = service
    }

    var completedCount: Int {
        items.filter { $0.isDone }.count
    }

    @discardableResult
    func createTask() -> Bool {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        items.append(MilestoneTask(title: trimmed, category: "Local"))
        newTitle = ""
        return true
    }

    func toggleTask(_ id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].isDone.toggle()
    }

    func removeTasks(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func syncBothSourcesConcurrently() {
        syncJob?.cancel()
        syncPhase = .loading

        let failFlag = simulateFailure
        let remoteService = service

        syncJob = Task {
            do {
                async let sprintBatch = remoteService.fetchSprintTasks(shouldFail: failFlag)
                async let backlogBatch = remoteService.fetchBacklogTasks(shouldFail: failFlag)

                let (sprintItems, backlogItems) = try await (sprintBatch, backlogBatch)
                try Task.checkCancellation()

                self.items = sprintItems + backlogItems
                self.syncPhase = .success
            } catch is CancellationError {
                self.syncPhase = .cancelled
            } catch {
                self.syncPhase = .error(error.localizedDescription)
            }
        }
    }

    func cancelActiveSync() {
        syncJob?.cancel()
        syncJob = nil
        syncPhase = .cancelled
    }
}

struct Milestone2TaskBoardView: View {
    @StateObject private var viewModel = MilestoneTaskViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HStack {
                    TextField("Add local task...", text: $viewModel.newTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        viewModel.createTask()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                Toggle("Simulate Network Error", isOn: $viewModel.simulateFailure)
                    .padding(.horizontal)

                HStack(spacing: 12) {
                    Button("Sync 2 Sources") {
                        viewModel.syncBothSourcesConcurrently()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.syncPhase == .loading)

                    if viewModel.syncPhase == .loading {
                        Button("Cancel", role: .destructive) {
                            viewModel.cancelActiveSync()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                statusBanner

                List {
                    ForEach(viewModel.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .strikethrough(item.isDone)
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isDone ? .green : .secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleTask(item.id)
                        }
                    }
                    .onDelete(perform: viewModel.removeTasks)
                }
            }
            .navigationTitle("M2 Task Board (\(viewModel.completedCount)/\(viewModel.items.count))")
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch viewModel.syncPhase {
        case .idle:
            Text("Ready to sync")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                Text("Fetching Sprint & Backlog concurrently...")
                    .font(.caption)
            }
        case .success:
            Text("Synced \(viewModel.items.count) combined tasks")
                .font(.caption)
                .foregroundStyle(.green)
        case .error(let message):
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        case .cancelled:
            Text("Sync cancelled by user")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }
}

@MainActor
func verifyMilestone2ViewModelLogic() async {
    let vm = MilestoneTaskViewModel()

    vm.newTitle = "   "
    assert(vm.createTask() == false)

    vm.newTitle = "Write Viva Summary"
    assert(vm.createTask() == true)
    assert(vm.items.count == 1)

    let id = vm.items[0].id
    vm.toggleTask(id)
    assert(vm.completedCount == 1)

    vm.syncBothSourcesConcurrently()
    try? await Task.sleep(nanoseconds: 1_100_000_000)
    assert(vm.syncPhase == .success)
    assert(vm.items.count == 4)

    vm.simulateFailure = true
    vm.syncBothSourcesConcurrently()
    try? await Task.sleep(nanoseconds: 1_100_000_000)
    if case .error = vm.syncPhase {
        assert(true)
    } else {
        assertionFailure("Expected error state")
    }

    vm.simulateFailure = false
    vm.syncBothSourcesConcurrently()
    try? await Task.sleep(nanoseconds: 150_000_000)
    vm.cancelActiveSync()
    assert(vm.syncPhase == .cancelled)
}
