import UIKit

struct LearnerProfileData: Equatable {
    let fullName: String
    let emailAddress: String
    let selectedCourse: String
}

enum ProfileFormValidator {
    static func validate(name: String, email: String, course: String) -> (nameError: String?, emailError: String?, courseError: String?) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCourse = course.trimmingCharacters(in: .whitespacesAndNewlines)

        let nameIssue = cleanName.count >= 2 ? nil : "Enter at least 2 characters for your full name."

        let parts = cleanEmail.split(separator: "@", omittingEmptySubsequences: false)
        let validEmail = parts.count == 2 && !parts[0].isEmpty && parts[1].contains(".") && !parts[1].hasPrefix(".") && !parts[1].hasSuffix(".")
        let emailIssue = validEmail ? nil : "Enter a valid email address (e.g. name@domain.com)."

        let courseIssue = !cleanCourse.isEmpty ? nil : "Enter your enrolled course title."

        return (nameIssue, emailIssue, courseIssue)
    }
}

final class ProfileFormContainerView: UIView {
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.keyboardDismissMode = .interactive
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Learner Profile Setup"
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.accessibilityTraits = .header
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Full Name"
        field.borderStyle = .roundedRect
        field.keyboardType = .default
        field.textContentType = .name
        field.autocapitalizationType = .words
        field.returnKeyType = .next
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.accessibilityLabel = "Full Name Input"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    let nameErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email Address"
        field.borderStyle = .roundedRect
        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.accessibilityLabel = "Email Address Input"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let courseField: UITextField = {
        let field = UITextField()
        field.placeholder = "Course Name (e.g. iOS Swift)"
        field.borderStyle = .roundedRect
        field.keyboardType = .default
        field.textContentType = .organizationName
        field.autocapitalizationType = .words
        field.returnKeyType = .done
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.accessibilityLabel = "Course Name Input"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    let courseErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let submitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Save Profile"
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.accessibilityLabel = "Save Profile Button"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let confirmationBanner: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemGreen
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAutoLayout() {
        let stack = UIStackView(arrangedSubviews: [
            headerLabel,
            nameField,
            nameErrorLabel,
            emailField,
            emailErrorLabel,
            courseField,
            courseErrorLabel,
            submitButton,
            confirmationBanner
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(4, after: nameField)
        stack.setCustomSpacing(4, after: emailField)
        stack.setCustomSpacing(4, after: courseField)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
}

final class ProfileFormViewController: UIViewController, UITextFieldDelegate {
    private let formView = ProfileFormContainerView()
    private(set) var savedProfile: LearnerProfileData?

    override func loadView() {
        view = formView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        formView.nameField.delegate = self
        formView.emailField.delegate = self
        formView.courseField.delegate = self

        formView.submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === formView.nameField {
            formView.emailField.becomeFirstResponder()
        } else if textField === formView.emailField {
            formView.courseField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            handleSubmit()
        }
        return true
    }

    @objc private func handleSubmit() {
        view.endEditing(true)

        let nameInput = formView.nameField.text ?? ""
        let emailInput = formView.emailField.text ?? ""
        let courseInput = formView.courseField.text ?? ""

        let issues = ProfileFormValidator.validate(name: nameInput, email: emailInput, course: courseInput)

        applyInlineError(issues.nameError, to: formView.nameErrorLabel)
        applyInlineError(issues.emailError, to: formView.emailErrorLabel)
        applyInlineError(issues.courseError, to: formView.courseErrorLabel)

        guard issues.nameError == nil, issues.emailError == nil, issues.courseError == nil else {
            formView.confirmationBanner.isHidden = true
            return
        }

        let profile = LearnerProfileData(
            fullName: nameInput.trimmingCharacters(in: .whitespacesAndNewlines),
            emailAddress: emailInput.trimmingCharacters(in: .whitespacesAndNewlines),
            selectedCourse: courseInput.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        savedProfile = profile
        formView.confirmationBanner.text = "Saved profile for \(profile.fullName) (\(profile.selectedCourse))"
        formView.confirmationBanner.isHidden = false
    }

    private func applyInlineError(_ message: String?, to label: UILabel) {
        label.text = message
        label.isHidden = (message == nil)
    }
}

func runProfileFormValidationChecks() {
    let invalidAll = ProfileFormValidator.validate(name: "A", email: "bad-email", course: "   ")
    assert(invalidAll.nameError != nil)
    assert(invalidAll.emailError != nil)
    assert(invalidAll.courseError != nil)

    let invalidDomain = ProfileFormValidator.validate(name: "Love Pandey", email: "love@.com", course: "iOS")
    assert(invalidDomain.nameError == nil)
    assert(invalidDomain.emailError != nil)
    assert(invalidDomain.courseError == nil)

    let validCase = ProfileFormValidator.validate(name: "Love Pandey", email: "love@example.com", course: "iOS Swift")
    assert(validCase.nameError == nil)
    assert(validCase.emailError == nil)
    assert(validCase.courseError == nil)
}
