//
//  ForgotPasswordViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 23.03.2025.
//
import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(emailTextField)
    }


    @IBAction func submitTapped(_ sender: UIButton) {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите email")
            return
        }

        sendForgotPasswordRequest(email: email)
    }

    private func sendForgotPasswordRequest(email: String) {
        guard let url = URL(string: "http://localhost:8080/auth/forgot-password") else { return }

        let body: [String: String] = ["email": email]
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

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    self.showAlert(title: "Ошибка", message: "Нет ответа от сервера.")
                    return
                }

                if httpResponse.statusCode == 200 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let message = json["message"] as? String {
                            
                            // Показать alert с переходом
                            let alert = UIAlertController(title: "Успешно", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Продолжить", style: .default, handler: { _ in
                                self.navigateToVerifyForgot(email: email)
                            }))
                            self.present(alert, animated: true)
                            
                        } else {
                            self.showAlert(title: "Успешно", message: "Код восстановления отправлен.")
                        }
                    } catch {
                        self.showAlert(title: "Успешно", message: "Код восстановления отправлен.")
                    }
                } else {
                    self.showAlert(title: "Ошибка", message: "Ошибка сервера. Код: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }


    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func navigateToVerifyForgot(email: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyForgotPasswordViewController") as? VerifyForgotPasswordViewController {
            verifyVC.email = email
            self.navigationController?.pushViewController(verifyVC, animated: true)
        }
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.clipsToBounds = true
    }
}
