import UIKit

struct TaskItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

enum TaskFilterOption: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

final class TaskBoardView: UIView {
    let titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter new task"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    let addButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Add"
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let filterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: TaskFilterOption.allCases.map { $0.rawValue })
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        let inputRow = UIStackView(arrangedSubviews: [titleField, addButton])
        inputRow.axis = .horizontal
        inputRow.spacing = 8
        inputRow.translatesAutoresizingMaskIntoConstraints = false

        addSubview(inputRow)
        addSubview(filterControl)
        addSubview(tableView)

        NSLayoutConstraint.activate([
            inputRow.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            inputRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            inputRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            filterControl.topAnchor.constraint(equalTo: inputRow.bottomAnchor, constant: 12),
            filterControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            filterControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

final class TaskListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let boardView = TaskBoardView()
    private var allTasks: [TaskItem] = []
    private var visibleTasks: [TaskItem] = []

    override func loadView() {
        view = boardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        boardView.tableView.dataSource = self
        boardView.tableView.delegate = self
        boardView.addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        boardView.filterControl.addTarget(self, action: #selector(didChangeFilter), for: .valueChanged)
    }

    @objc private func didTapAdd() {
        let trimmed = (boardView.titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        allTasks.append(TaskItem(title: trimmed))
        boardView.titleField.text = ""
        refreshVisibleTasks()
    }

    @objc private func didChangeFilter() {
        refreshVisibleTasks()
    }

    private func refreshVisibleTasks() {
        let selectedIndex = boardView.filterControl.selectedSegmentIndex
        let activeFilter = TaskFilterOption.allCases[selectedIndex]
        switch activeFilter {
        case .all:
            visibleTasks = allTasks
        case .active:
            visibleTasks = allTasks.filter { !$0.isCompleted }
        case .completed:
            visibleTasks = allTasks.filter { $0.isCompleted }
        }
        boardView.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TaskCell")
        let item = visibleTasks[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isCompleted ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetID = visibleTasks[indexPath.row].id
        if let idx = allTasks.firstIndex(where: { $0.id == targetID }) {
            allTasks[idx].isCompleted.toggle()
            refreshVisibleTasks()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let targetID = visibleTasks[indexPath.row].id
            allTasks.removeAll { $0.id == targetID }
            refreshVisibleTasks()
        }
    }
}
