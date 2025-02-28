//
//  SignUpViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 27.12.2024.
//

import UIKit

class SignUpViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confPassTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
        configureTextField(confPassTextField)
        configureButton(signUpButton)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton){
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confPassTextField.text, confirmPassword == password else {
            print("⚠️ Please enter valid email and matching passwords")
            return
        }
        
        registerUser(email: email, password: password)
    }
    
    private func registerUser(email: String, password: String) {
        let url = URL(string: "http://localhost:8080/auth/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")

                return
            }
            
            let jsonString = String(data: data, encoding: .utf8) ?? "No response body"
            print("📩 Raw Response from Server: \(jsonString)")
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = jsonResponse["access_token"] as? String,
                   let user = jsonResponse["user"] as? [String: Any],
                   let userId = user["id"] as? String {
                    
                    print("✅ Successfully signed up!")
                    print("🔑 Token: \(accessToken)")
                    print("🆔 User ID: \(userId)")
                    
                    self.saveUserSession(accessToken: accessToken, userId: userId)
                    
                    DispatchQueue.main.async {
                        self.navigateToSignIn()
                    }
                } else {
                    print("⚠️ Unexpected JSON structure. Check server response.")
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func saveUserSession(accessToken: String, userId: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(accessToken, forKey: "access_token")
        defaults.setValue(userId, forKey: "user_id")
    }
    
    func navigateToSignIn() {
        DispatchQueue.main.async {
            if let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRegisterViewController") {
                self.navigationController?.pushViewController(signInVC, animated: true)
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
    
//    func addLeftPadding(to textField: UITextField, padding: CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
//        textField.leftView = paddingView
//        textField.leftViewMode = .always
//    }
}
