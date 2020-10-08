import UIKit
import Combine

final class CombineLoginViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.placeholder = "blob@email.com"
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LogIn", for: .normal)
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

        let emailPublisher = emailTextField
            .textPublisher
            .compactMap { $0 }

        let passwordPublisher = passwordTextField
            .textPublisher
            .compactMap { $0 }

        let emailAndPasswordPublisher = Publishers.CombineLatest(
            emailPublisher,
            passwordPublisher
        )

        emailAndPasswordPublisher
            .map { email, password in
                isEmailValid(email: email) && isPasswordValid(password: password)
            }.assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)

        loginButton
            .tapPublisher
            .map { emailAndPasswordPublisher }
            .switchToLatest()
            .sink { [weak self] email, password in
                self?.didTapLogin(email: email, password: password)
            }.store(in: &cancellables)
    }

    private func didTapLogin(email: String, password: String) {
        print(">>> Login \(email) \(password)")
    }
}

private func isEmailValid(email: String) -> Bool {
    email.contains("@")
}

private func isPasswordValid(password: String) -> Bool {
    password.count >= 5
}

extension UITextField {
    /// A publisher emitting any text changes to a this text field.
    var textPublisher: AnyPublisher<String?, Never> {
        Publishers.ControlProperty(
            control: self,
            events: .defaultValueEvents,
            keyPath: \.text
        )
        .eraseToAnyPublisher()
    }
}

extension UIButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .touchUpInside)
    }
}

extension UIControl {
    /// A publisher emitting events from this control.
    func controlEventPublisher(
        for events: UIControl.Event
    ) -> AnyPublisher<Void, Never> {
        Publishers.ControlEvent(
            control: self,
            events: events
        )
        .eraseToAnyPublisher()
    }
}
