//
//  VerifyForgotPassViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 23.03.2025.
//

import UIKit

class VerifyForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!

    var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = "Код отправлен на почту \(email)"
        configureTextField(codeTextField)
        configureTextField(newPasswordTextField)
        configureTextField(confirmPasswordTextField)
    }

    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        let code = codeTextField.text ?? ""
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""

        guard !code.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            showAlert(title: "Ошибка", message: "Заполните все поля.")
            return
        }

        guard newPassword == confirmPassword else {
            showAlert(title: "Ошибка", message: "Пароли не совпадают.")
            return
        }

        sendResetRequest(code: code, email: email, newPassword: newPassword)
    }

    private func sendResetRequest(code: String, email: String, newPassword: String) {
        guard let url = URL(string: "http://localhost:8080/auth/forgot-password/verify") else { return }

        let body: [String: String] = [
            "code": code,
            "email": email,
            "new_password": newPassword
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            showAlert(title: "Ошибка", message: "Не удалось закодировать данные.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Ошибка", message: "Сетевая ошибка: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(title: "Ошибка", message: "Нет ответа от сервера.")
                    return
                }

                if httpResponse.statusCode == 200 {
                    self.showAlert(title: "Успешно", message: "Пароль успешно сброшен.") { _ in
                        self.navigateToLogin()
                    }
                } else {
                    self.showAlert(title: "Ошибка", message: "Ошибка сервера. Код: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    private func navigateToLogin() {
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") {
            navigationController?.pushViewController(signInVC, animated: true)
        }
    }

    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.clipsToBounds = true
    }
}
