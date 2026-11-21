import UIKit

final class LifecycleAuditLog {
    static let shared = LifecycleAuditLog()
    private(set) var events: [String] = []

    func append(_ entry: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let stamped = "[\(formatter.string(from: Date()))] \(entry)"
        events.append(stamped)
        print(stamped)
    }
}

final class ControlsPlaygroundViewController: UIViewController, UITextFieldDelegate {

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .interactive
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private let sessionTitleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter study session topic"
        field.borderStyle = .roundedRect
        field.returnKeyType = .done
        field.accessibilityLabel = "Study Session Topic Field"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let modeSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Solo", "Pair", "Group"])
        control.selectedSegmentIndex = 0
        control.accessibilityLabel = "Study Mode Selector"
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let reminderSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.accessibilityLabel = "Break Reminder Toggle"
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 15
        slider.maximumValue = 90
        slider.value = 45
        slider.accessibilityLabel = "Session Duration Slider"
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private let summaryCardLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.accessibilityLabel = "Live Configuration Summary"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let inspectLifecycleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Open Lifecycle Report Screen"
        let button = UIButton(configuration: config)
        button.accessibilityLabel = "Open Lifecycle Report Screen Button"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var appearanceCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Lab 7C Controls"

        LifecycleAuditLog.shared.append("Screen 1 (Controls): viewDidLoad")
        setupLayout()
        wireControlTargets()
        refreshSummaryPanel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appearanceCount += 1
        LifecycleAuditLog.shared.append("Screen 1 (Controls): viewWillAppear (#\(appearanceCount))")
        refreshSummaryPanel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LifecycleAuditLog.shared.append("Screen 1 (Controls): viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LifecycleAuditLog.shared.append("Screen 1 (Controls): viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LifecycleAuditLog.shared.append("Screen 1 (Controls): viewDidDisappear")
    }

    private func setupLayout() {
        let reminderLabel = UILabel()
        reminderLabel.text = "Enable 5-Min Break Alerts"
        reminderLabel.font = .preferredFont(forTextStyle: .body)
        reminderLabel.textColor = .label

        let reminderRow = UIStackView(arrangedSubviews: [reminderLabel, reminderSwitch])
        reminderRow.axis = .horizontal
        reminderRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            sessionTitleField,
            modeSegment,
            reminderRow,
            durationSlider,
            summaryCardLabel,
            inspectLifecycleButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func wireControlTargets() {
        sessionTitleField.delegate = self
        sessionTitleField.addTarget(self, action: #selector(controlDidChange), for: .editingChanged)
        modeSegment.addTarget(self, action: #selector(controlDidChange), for: .valueChanged)
        reminderSwitch.addTarget(self, action: #selector(controlDidChange), for: .valueChanged)
        durationSlider.addTarget(self, action: #selector(controlDidChange), for: .valueChanged)
        inspectLifecycleButton.addTarget(self, action: #selector(pushReportScreen), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func controlDidChange() {
        refreshSummaryPanel()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func refreshSummaryPanel() {
        let rawTopic = (sessionTitleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let topic = rawTopic.isEmpty ? "Untitled Session" : rawTopic
        let modes = ["Solo", "Pair", "Group"]
        let chosenMode = modes[modeSegment.selectedSegmentIndex]
        let alerts = reminderSwitch.isOn ? "On" : "Off"
        let minutes = Int(durationSlider.value.rounded())

        summaryCardLabel.text = """
         Live Summary (Screen Visits: \(appearanceCount))
         • Topic: \(topic)
         • Mode: \(chosenMode)
         • Duration: \(minutes) mins
         • Break Alerts: \(alerts)
        """
    }

    @objc private func pushReportScreen() {
        view.endEditing(true)
        let reportVC = LifecycleLogDetailViewController()
        navigationController?.pushViewController(reportVC, animated: true)
    }
}

final class LifecycleLogDetailViewController: UIViewController {
    private let logTextView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        view.textColor = .label
        view.backgroundColor = .secondarySystemBackground
        view.accessibilityLabel = "Recorded View Lifecycle Log"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Lifecycle Log"
        LifecycleAuditLog.shared.append("Screen 2 (Report): viewDidLoad")

        view.addSubview(logTextView)
        NSLayoutConstraint.activate([
            logTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LifecycleAuditLog.shared.append("Screen 2 (Report): viewWillAppear")
        logTextView.text = LifecycleAuditLog.shared.events.joined(separator: "\n")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LifecycleAuditLog.shared.append("Screen 2 (Report): viewDidAppear")
        logTextView.text = LifecycleAuditLog.shared.events.joined(separator: "\n")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LifecycleAuditLog.shared.append("Screen 2 (Report): viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LifecycleAuditLog.shared.append("Screen 2 (Report): viewDidDisappear")
    }
}
