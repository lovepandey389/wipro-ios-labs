import UIKit

final class QueueMonitorViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "GCD & Main-Thread UI Monitor"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let runTaskButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Run Background Sync"
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let concurrentButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Run 2 Concurrent Tasks"
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activitySpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Idle — Ready to start"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private var isJobRunning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        runTaskButton.addTarget(self, action: #selector(handleSingleSyncTap), for: .touchUpInside)
        concurrentButton.addTarget(self, action: #selector(handleConcurrentSyncTap), for: .touchUpInside)
        appendQueueLog("viewDidLoad initialized")
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            runTaskButton,
            concurrentButton,
            activitySpinner,
            statusLabel,
            logTextView
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setLoadingState(_ loading: Bool, message: String) {
        isJobRunning = loading
        runTaskButton.isEnabled = !loading
        concurrentButton.isEnabled = !loading
        statusLabel.text = message
        if loading {
            activitySpinner.startAnimating()
        } else {
            activitySpinner.stopAnimating()
        }
    }

    private func appendQueueLog(_ step: String) {
        let queueLabel = String(cString: __dispatch_queue_get_label(nil))
        let threadKind = Thread.isMainThread ? "MAIN THREAD" : "BACKGROUND THREAD"
        let line = "[\(threadKind) | \(queueLabel)] \(step)"
        print(line)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logTextView.text += line + "\n"
        }
    }

    @objc private func handleSingleSyncTap() {
        guard !isJobRunning else { return }
        setLoadingState(true, message: "Processing heavy task off main queue...")
        appendQueueLog("1. Button tapped & UI locked")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.appendQueueLog("2. Started slow computation on global queue")
            Thread.sleep(forTimeInterval: 1.5)
            let computedChecksum = (1...50_000).reduce(0, +)

            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.appendQueueLog("3. Delayed network response arrived via asyncAfter")

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.appendQueueLog("4. Restoring UI on DispatchQueue.main")
                    self.setLoadingState(false, message: "Completed! Checksum: \(computedChecksum)")
                }
            }
        }
    }

    @objc private func handleConcurrentSyncTap() {
        guard !isJobRunning else { return }
        setLoadingState(true, message: "Running 2 concurrent tasks...")
        appendQueueLog("Concurrent batch started")

        let group = DispatchGroup()
        var profileSummary = ""
        var gradesSummary = ""

        group.enter()
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.appendQueueLog("Task A (Profile) finished")
            profileSummary = "Love Pandey (Wipro iOS)"
            group.leave()
        }

        group.enter()
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.appendQueueLog("Task B (Grades) finished")
            gradesSummary = "5 Labs Completed"
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.appendQueueLog("DispatchGroup notified on main queue")
            self.setLoadingState(false, message: "\(profileSummary) | \(gradesSummary)")
        }
    }
}
