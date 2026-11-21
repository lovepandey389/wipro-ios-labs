import UIKit

struct TrainingTopic: Equatable {
    let code: String
    let title: String
    let summary: String
    let durationMinutes: Int
}

final class ModuleCatalogCell: UITableViewCell {
    static let reuseIdentifier = "ModuleCatalogCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        setupCellLayout()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    private func setupCellLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with topic: TrainingTopic) {
        titleLabel.text = topic.title
        subtitleLabel.text = "\(topic.code) • \(topic.durationMinutes) mins"
    }
}

final class TopicListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var topics: [TrainingTopic]
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No topics available.\nTap Reload to restore sample modules."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    init(topics: [TrainingTopic] = TopicListViewController.defaultTopics) {
        self.topics = topics
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.topics = TopicListViewController.defaultTopics
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit Modules"
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureTableView()
        updateEmptyState()
    }

    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Toggle Empty",
            style: .plain,
            target: self,
            action: #selector(toggleSampleData)
        )
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ModuleCatalogCell.self, forCellReuseIdentifier: ModuleCatalogCell.reuseIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateEmptyState() {
        tableView.backgroundView = topics.isEmpty ? emptyStateLabel : nil
    }

    @objc private func toggleSampleData() {
        topics = topics.isEmpty ? TopicListViewController.defaultTopics : []
        updateEmptyState()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ModuleCatalogCell.reuseIdentifier,
            for: indexPath
        ) as? ModuleCatalogCell else {
            return UITableViewCell()
        }
        cell.configure(with: topics[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chosenTopic = topics[indexPath.row]
        let detailController = TopicDetailViewController(topic: chosenTopic)
        navigationController?.pushViewController(detailController, animated: true)
    }

    static let defaultTopics: [TrainingTopic] = [
        TrainingTopic(
            code: "UIK-101",
            title: "UIWindow & View Hierarchy",
            summary: "Inspect parent-child subview trees, bounds vs. frame, and safe area layout guides.",
            durationMinutes: 45
        ),
        TrainingTopic(
            code: "UIK-102",
            title: "UINavigationController Stack",
            summary: "Push and pop view controllers while passing value-type models safely via initializers.",
            durationMinutes: 50
        ),
        TrainingTopic(
            code: "UIK-103",
            title: "Reusable UITableViewCells",
            summary: "Dequeue custom cells cleanly without force-unwrapped IBOutlets.",
            durationMinutes: 60
        )
    ]
}

final class TopicDetailViewController: UIViewController {
    private let topic: TrainingTopic

    private let codeBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headingLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(topic: TrainingTopic) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = topic.code
        view.backgroundColor = .systemBackground
        setupDetailLayout()
        populateTopic()
    }

    private func setupDetailLayout() {
        let stack = UIStackView(arrangedSubviews: [
            codeBadgeLabel,
            headingLabel,
            durationLabel,
            summaryLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func populateTopic() {
        codeBadgeLabel.text = "MODULE CODE: \(topic.code)"
        headingLabel.text = topic.title
        durationLabel.text = "Estimated Duration: \(topic.durationMinutes) minutes"
        summaryLabel.text = topic.summary
    }
}
