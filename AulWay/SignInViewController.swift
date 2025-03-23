//
//  SignInViewController.swift
//  AulWay
//
//  Created by Tomiris on 25.12.2024.
//

import UIKit

class SignInViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var wrongPasswordLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
        configureButton(signInButton)
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("⚠️ Please enter both email and password")
            showAlert(title: "Missing Information", message: "Please enter both email and password.")
            return
        }
        
        authenticateUser(email: email, password: password)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func authenticateUser(email: String, password: String) {
        let url = URL(string: "http://localhost:8080/auth/signin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.showErrorMessage("Ошибка сети. Пожалуйста, попробуйте снова.")
                }
                return
            }
            
            let jsonString = String(data: data, encoding: .utf8) ?? "No response body"
//            print("Raw Response from Server: \(jsonString)")
            
            do {
                
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("⚠️ JSON Parsing Failed - Invalid format")
                    DispatchQueue.main.async {
                        self.showErrorMessage("Недопустимый формат ответа сервера.")
                    }
                    return
                }
                
//                print("📌 Parsed JSON: \(jsonResponse)")
                
                
                if let errorMessage = jsonResponse["errDesc"] as? String {
                    print("⚠️ Server Error: \(errorMessage)")
                    DispatchQueue.main.async {
                        self.showErrorMessage(errorMessage)
                    }
                    return
                }
                
                
                if let accessToken = jsonResponse["access_token"] as? String,
                   let user = jsonResponse["user"] as? [String: Any],
                   let userId = user["id"] as? String,
                   let firstName = user["firstname"] as? String,
                   let lastName = user["lastname"] as? String,
                   let email = user["email"] as? String,
                   let phone = user["phone"] as? String {
                    
                    print("✅ Successfully signed in!")
                    print("🔑 Token: \(accessToken)")
                    print("🆔 User ID: \(userId)")
                    print("👤 First Name: \(firstName), Last Name: \(lastName)")
                    print("📧 Email: \(email), 📱 Phone: \(phone)")
                    
                    self.saveUserSession(accessToken: accessToken, userId: userId, email: email)
                    
                    UserDefaults.standard.set(userId, forKey: "id")
                    UserDefaults.standard.set(accessToken, forKey: "authToken")
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.async {
                        self.navigateToHome()
                    }
                } else {
                    print("⚠️ Unexpected JSON structure. Missing fields.")
                    DispatchQueue.main.async {
                        self.showErrorMessage("Unexpected server response.")
                    }
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorMessage("Error parsing server response.")
                }
            }
        }
        task.resume()
    }
    
    
    private func showErrorMessage(_ message: String) {
        wrongPasswordLabel.text = message
        wrongPasswordLabel.textColor = .red
        wrongPasswordLabel.isHidden = false
    }
    
    
    private func saveUserSession(accessToken: String, userId: String, email: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(accessToken, forKey: "access_token")
        defaults.setValue(userId, forKey: "user_id")
        defaults.setValue(email, forKey: "email")
    }
    
    private func navigateToHome() {
        DispatchQueue.main.async {
            if let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "Tickets") {
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: true, completion: nil)
            }
        }
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
}
