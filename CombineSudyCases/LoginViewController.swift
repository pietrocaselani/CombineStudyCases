import UIKit

final class LoginViewController: UIViewController {
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.placeholder = "blob@email.com"
        textField.addTarget(
            self,
            action: #selector(textFieldTextChanged),
            for: .editingChanged
        )

        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        textField.addTarget(
            self,
            action: #selector(textFieldTextChanged),
            for: .editingChanged
        )

        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LogIn", for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        let stackView = UIStackView(
            arrangedSubviews: [
                emailTextField,
                passwordTextField,
                loginButton
            ]
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        view.addSubview(stackView)

        stackView
            .centerYAnchor
            .constraint(equalTo: view.centerYAnchor)
            .isActive = true

        stackView
            .centerXAnchor
            .constraint(equalTo: view.centerXAnchor)
            .isActive = true
    }

    @objc private func textFieldTextChanged() {
        let emailValid = isEmailValid(email: emailTextField.text ?? "")
        let passwordValid = isPasswordValid(password: passwordTextField.text ?? "")

        loginButton.isEnabled = emailValid && passwordValid
    }

    @objc private func didTapLoginButton() {
        print(">>> login with \(emailTextField.text) \(passwordTextField.text)")
    }

    private func isEmailValid(email: String) -> Bool {
        email.contains("@")
    }

    private func isPasswordValid(password: String) -> Bool {
        password.count >= 5
    }
}
