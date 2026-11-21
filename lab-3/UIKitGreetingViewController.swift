import UIKit
import SwiftUI

final class UIKitGreetingViewController: UIViewController {

    private let headingLabel: UILabel = {
        let label = UILabel()
        label.text = "UIKit Check-In"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameInputField: UITextField = {
        let field = UITextField()
        field.placeholder = "Type your full name"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let submitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Generate Greeting"
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let outcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your name above to begin."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        assembleLayout()
        submitButton.addTarget(self, action: #selector(handleGreetingTap), for: .touchUpInside)
    }

    private func assembleLayout() {
        let stack = UIStackView(arrangedSubviews: [
            headingLabel,
            nameInputField,
            submitButton,
            outcomeLabel
        ])
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func handleGreetingTap() {
        let cleaned = (nameInputField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        outcomeLabel.text = cleaned.isEmpty
            ? "Please enter a valid name."
            : "Welcome to iOS Training, \(cleaned)!"
    }

    func presentEmbeddedSwiftUIScreen() {
        let hostController = UIHostingController(rootView: SwiftUIGreetingView())
        present(hostController, animated: true)
    }
}
