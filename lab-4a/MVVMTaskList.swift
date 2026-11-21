import SwiftUI
import Combine

final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var draftTitle: String = ""
    @Published var selectedFilter: TaskFilterOption = .all
    @Published private(set) var validationMessage: String?

    var filteredTasks: [TaskItem] {
        switch selectedFilter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }

    @discardableResult
    func addTask() -> Bool {
        let cleaned = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            validationMessage = "Task title cannot be empty."
            return false
        }
        tasks.append(TaskItem(title: cleaned))
        draftTitle = ""
        validationMessage = nil
        return true
    }

    func toggleCompletion(for taskID: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func deleteTasks(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredTasks[$0].id }
        tasks.removeAll { idsToDelete.contains($0.id) }
    }
}

struct MVVMTaskListView: View {
    @StateObject private var viewModel = TaskViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Enter new task", text: $viewModel.draftTitle)
                        .textFieldStyle(.roundedBorder)

                    Button("Add") {
                        viewModel.addTask()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                if let errorText = viewModel.validationMessage {
                    Text(errorText)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(TaskFilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    ForEach(viewModel.filteredTasks) { task in
                        HStack {
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                            Spacer()
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isCompleted ? .green : .secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleCompletion(for: task.id)
                        }
                    }
                    .onDelete(perform: viewModel.deleteTasks)
                }
            }
            .navigationTitle("MVVM Tasks")
        }
    }
}

func runTaskViewModelUnitChecks() {
    let vm = TaskViewModel()
    vm.draftTitle = "   "
    assert(vm.addTask() == false)
    assert(vm.validationMessage != nil)

    vm.draftTitle = "Complete Lab 4A"
    assert(vm.addTask() == true)
    assert(vm.tasks.count == 1)

    let addedID = vm.tasks[0].id
    vm.toggleCompletion(for: addedID)
    assert(vm.tasks[0].isCompleted == true)

    vm.selectedFilter = .active
    assert(vm.filteredTasks.isEmpty)

    vm.selectedFilter = .completed
    assert(vm.filteredTasks.count == 1)

    vm.deleteTasks(at: IndexSet(integer: 0))
    assert(vm.tasks.isEmpty)
}
