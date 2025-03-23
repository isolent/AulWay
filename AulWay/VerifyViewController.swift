//
//  VerifyViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 23.03.2025.
//

import UIKit

class VerifyViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!

    var email: String = ""
    var password: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = email
    }

    @IBAction func verifyTapped(_ sender: UIButton) {
        let code = codeTextField.text ?? ""
        sendVerification(code: code, email: email, password: password)
    }

    func sendVerification(code: String, email: String, password: String) {
        guard let url = URL(string: "http://localhost:8080/auth/signup/verify") else { return }

        let body: [String: String] = [
            "code": code,
            "email": email,
            "password": password
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to encode body:", error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API error:", error)
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка", message: "Не удалось подключиться к серверу.")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка", message: "Неверный ответ от сервера.")
                }
                return
            }

            if let data = data {
                let responseString = String(data: data, encoding: .utf8) ?? "No readable data"
                print("Server response:", responseString)
            }

            if httpResponse.statusCode == 200, let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let user = json["user"] as? [String: Any],
                       let userId = user["id"] as? String {

                        UserDefaults.standard.setValue(self.email, forKey: "email")
                        UserDefaults.standard.setValue(userId, forKey: "user_id")

                        if let token = json["access_token"] as? String {
                            UserDefaults.standard.setValue(token, forKey: "access_token")
//                            print("🔐 Saved access_token:", token.prefix(16) + "...")
                        }
                    }
                } catch {
                    print("⚠️ Failed to parse verification response:", error)
                }

                DispatchQueue.main.async {
                    let alert = UIAlertController(
                            title: "Успешно!",
                            message: "Вы успешно зарегистрировались.",
                            preferredStyle: .alert
                        )

                        alert.addAction(UIAlertAction(title: "Войти", style: .default, handler: { _ in
                            self.navigateToSignIn()
                        }))

                        self.present(alert, animated: true, completion: nil)
                }
            } else {
                if let data = data {
                    do {
                        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let message = json?["message"] as? String ?? "Ошибка верификации. Попробуйте снова."
                        DispatchQueue.main.async {
                            self.showAlert(title: "Ошибка", message: message)
                        }
                    } catch {
                        print("JSON parse fallback error:", error)
                        DispatchQueue.main.async {
                            self.showAlert(title: "Ошибка", message: "Неверный формат ответа от сервера.")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Ошибка", message: "Ответ от сервера отсутствует.")
                    }
                }
            }
        }.resume()
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func navigateToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            self.navigationController?.pushViewController(signInVC, animated: true)
        }
    }
}

struct ServerErrorResponse: Decodable {
    let message: String?
}
