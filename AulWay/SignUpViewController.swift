//
//  SignUpViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 27.12.2024.
//

import UIKit

class SignUpViewController: BaseViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confPassTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
        configureTextField(confPassTextField)
        configureButton(signUpButton)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите email и пароль")
            return
        }

        registerUser(email: email, password: password)
    }
    
    private func registerUser(email: String, password: String) {
        guard let url = URL(string: "\(BASE_URL)/auth/signup") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
//                print("📡 Server responded with code: \(httpResponse.statusCode)")
            }

            guard let data = data, error == nil else {
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка", message: "Проблема с сетью. Повторите попытку.")
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    print("📦 Full JSON Response: \(jsonResponse)")

                    if let errorMessage = jsonResponse["errDesc"] as? String,
                       errorMessage.lowercased().contains("email already exists") {
//                        print("⚠️ Email already registered. Navigating to UserExistsViewController.")
                        DispatchQueue.main.async {
                            self.navigateToUserExists()
                        }
                        return
                    }


                    if let message = jsonResponse["message"] as? String {
                        print("✅ \(message)")

                        DispatchQueue.main.async {
                            guard let verifyVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyViewController") as? VerifyViewController else {
                                print("❌ Could not load VerifyViewController")
                                return
                            }
                            verifyVC.email = email
                            verifyVC.password = password

                            if let nav = self.navigationController {
                                nav.pushViewController(verifyVC, animated: true)
                            } else {
                                verifyVC.modalPresentationStyle = .fullScreen
                                self.present(verifyVC, animated: true, completion: nil)
                            }
                        }
                    } else {
                        print("⚠️ 'message' not found in response.")
                        DispatchQueue.main.async {
                            self.showAlert(title: "Ошибка", message: "Не удалось завершить регистрацию.")
                        }
                    }
                } else {
                    print("❌ Invalid JSON structure.")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Ошибка", message: "Неверный ответ от сервера.")
                    }
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка", message: "Ошибка при обработке ответа сервера.")
                }
            }
        }
        task.resume()
    }


    func navigateToUserExists() {
        DispatchQueue.main.async {
            if let userExistsVC = self.storyboard?.instantiateViewController(withIdentifier: "UserExistsViewController") {
                if let nav = self.navigationController {
                    nav.pushViewController(userExistsVC, animated: true)
                } else {
                    userExistsVC.modalPresentationStyle = .fullScreen
                    self.present(userExistsVC, animated: true, completion: nil)
                }
            } else {
                print("❌ Could not load UserExistsViewController")
            }
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") {
            signInVC.modalPresentationStyle = .fullScreen
            present(signInVC, animated: true, completion: nil)
        }
    }

    private func saveUserSession(accessToken: String, userId: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(accessToken, forKey: "access_token")
        defaults.setValue(userId, forKey: "user_id")
    }

    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.clipsToBounds = true
    }
    
    private func configureButton(_ button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = button.frame.height / 2
        button.clipsToBounds = true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
