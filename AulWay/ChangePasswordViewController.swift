//
//  ChangePasswordViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 23.02.2025.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var togglePasswordVisibilityButton: UIButton!

    private var isPasswordVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        configureTextField(currentPasswordTextField)
        configureTextField(newPasswordTextField)
        configureTextField(confirmNewPasswordTextField)

        currentPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        confirmNewPasswordTextField.isSecureTextEntry = true

        isPasswordVisible = false
        togglePasswordVisibilityButton.setTitle("Show password", for: .normal)
    }

    @IBAction func togglePasswordVisibilityTapped(_ sender: UIButton) {
        isPasswordVisible.toggle()

        // Изменить secureTextEntry без потери курсора
        toggleSecureEntry(for: currentPasswordTextField, visible: isPasswordVisible)
        toggleSecureEntry(for: newPasswordTextField, visible: isPasswordVisible)
        toggleSecureEntry(for: confirmNewPasswordTextField, visible: isPasswordVisible)

        let title = isPasswordVisible ? "Hide password" : "Show password"
        togglePasswordVisibilityButton.setTitle(title, for: .normal)
    }

    private func toggleSecureEntry(for textField: UITextField, visible: Bool) {
        let currentText = textField.text
        textField.isSecureTextEntry = !visible
        textField.text = nil
        textField.text = currentText
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
              let token = UserDefaults.standard.string(forKey: "access_token"),
              let email = UserDefaults.standard.string(forKey: "email") else {
            showAlert(title: "Ошибка", message: "Сессия недействительна.")
            return
        }

        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmNewPasswordTextField.text,
              !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            showAlert(title: "Ошибка", message: "Заполните все поля.")
            return
        }

        guard newPassword == confirmPassword else {
            showAlert(title: "Ошибка", message: "Новые пароли не совпадают.")
            return
        }

        sendChangePasswordRequest(userId: userId, email: email, oldPassword: currentPassword, newPassword: newPassword, token: token)
    }

    private func sendChangePasswordRequest(userId: String, email: String, oldPassword: String, newPassword: String, token: String) {
        let urlString = "http://localhost:8080/api/users/\(userId)/change-password"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Ошибка", message: "Неверный адрес сервера.")
            return
        }

        let body: [String: String] = [
            "email": email,
            "old_password": oldPassword,
            "new_password": newPassword
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            showAlert(title: "Ошибка", message: "Ошибка при формировании запроса.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Ошибка", message: "Сетевая ошибка: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    self.showAlert(title: "Ошибка", message: "Нет ответа от сервера.")
                    return
                }

                let responseText = String(data: data, encoding: .utf8) ?? "—"

                switch httpResponse.statusCode {
                case 200:
                    self.showAlert(title: "Успешно", message: responseText)
                case 403:
                    self.showAlert(title: "Ошибка", message: "Недостаточно прав для смены пароля. Проверьте email или токен.")
                case 400:
                    self.showAlert(title: "Ошибка", message: "Неверный текущий пароль.")
                default:
                    self.showAlert(title: "Ошибка", message: "Ошибка сервера. Код: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.clipsToBounds = true
    }
}
