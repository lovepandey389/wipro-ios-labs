import UIKit

final class FeedFilterFormAndListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    private let service = PostNetworkService()
    private var posts: [RemotePost] = []

    private let userIdField: UITextField = {
        let field = UITextField()
        field.placeholder = "Filter by User ID (1–10, or blank for all)"
        field.borderStyle = .roundedRect
        field.keyboardType = .numberPad
        field.accessibilityLabel = "User ID Filter Field"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let stateSelector: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Live API", "Empty State", "Error State"])
        control.selectedSegmentIndex = 0
        control.accessibilityLabel = "Response State Mode"
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let loadButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Validate & Fetch"
        let button = UIButton(configuration: config)
        button.accessibilityLabel = "Validate and Fetch Button"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let validationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let statusMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "M3 Posts Directory"
        view.backgroundColor = .systemBackground
        setupAutoLayout()
        configureActions()
        triggerFetch()
    }

    private func setupAutoLayout() {
        let formStack = UIStackView(arrangedSubviews: [
            userIdField,
            validationLabel,
            stateSelector,
            loadButton,
            spinner,
            statusMessageLabel
        ])
        formStack.axis = .vertical
        formStack.spacing = 10
        formStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(formStack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            formStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            formStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: formStack.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureActions() {
        userIdField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        loadButton.addTarget(self, action: #selector(didTapFetch), for: .touchUpInside)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapFetch() {
        view.endEditing(true)
        triggerFetch()
    }

    private func validateUserIDInput() -> (isValid: Bool, userID: Int?) {
        let raw = (userIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty {
            validationLabel.isHidden = true
            return (true, nil)
        }
        guard let parsed = Int(raw), (1...10).contains(parsed) else {
            validationLabel.text = "User ID must be a number between 1 and 10."
            validationLabel.isHidden = false
            return (false, nil)
        }
        validationLabel.isHidden = true
        return (true, parsed)
    }

    private func triggerFetch() {
        let check = validateUserIDInput()
        guard check.isValid else { return }

        let mode = stateSelector.selectedSegmentIndex
        let simulateEmpty = (mode == 1)
        let simulateError = (mode == 2)

        spinner.startAnimating()
        loadButton.isEnabled = false
        statusMessageLabel.text = "Loading posts..."
        statusMessageLabel.isHidden = false

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let fetched = try await self.service.fetchPosts(
                    userIDFilter: check.userID,
                    forceEmpty: simulateEmpty,
                    forceBadURL: simulateError
                )
                self.posts = fetched
                self.statusMessageLabel.isHidden = true
                self.tableView.reloadData()
            } catch {
                self.posts = []
                self.tableView.reloadData()
                self.statusMessageLabel.text = error.localizedDescription
                self.statusMessageLabel.isHidden = false
            }
            self.spinner.stopAnimating()
            self.loadButton.isEnabled = true
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "PostCell")
        let item = posts[indexPath.row]
        cell.textLabel?.text = item.title.capitalized
        cell.detailTextLabel?.text = "Post #\(item.id) • User \(item.userId)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPost = posts[indexPath.row]
        let detailVC = PostDetailViewController(post: selectedPost)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

final class PostDetailViewController: UIViewController {
    private let post: RemotePost

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(post: RemotePost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post #\(post.id)"
        view.backgroundColor = .systemBackground

        metaLabel.text = "AUTHOR ID: \(post.userId) • POST ID: \(post.id)"
        titleLabel.text = post.title.capitalized
        bodyLabel.text = post.body

        let stack = UIStackView(arrangedSubviews: [metaLabel, titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
