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
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let verifyVC = storyboard.instantiateViewController(withIdentifier: "VerifyViewController") as? VerifyViewController {
            verifyVC.email = email
            verifyVC.password = password
            self.navigationController?.pushViewController(verifyVC, animated: true)
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
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
//                    print("📦 Server JSON response: \(jsonResponse)") 
                    
                    if let errorMessage = jsonResponse["errDesc"] as? String, errorMessage == "email already exists" {
                        print("⚠️ Email already registered. Redirecting to UserExistsViewController.")
                        DispatchQueue.main.async {
                            self.navigateToUserExists()
                        }
                        return
                    }

                    let accessToken = jsonResponse["access_token"] as? String
                    let userDict = jsonResponse["user"] as? [String: Any]
                    let userId = userDict?["id"] as? String

                    if let accessToken = accessToken, let userId = userId {
                        print("✅ Successfully signed up!")
                        print("✅ Successfully signed up!")
                        print("🔑 Token: \(accessToken)")
                        print("🆔 User ID: \(userId)")
                        
                        self.saveUserSession(accessToken: accessToken, userId: userId)
                    }
                } else {
                    print("❌ Failed to parse JSON into dictionary.")
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }


    func navigateToUserExists() {
        DispatchQueue.main.async {
            if let userExistsVC = self.storyboard?.instantiateViewController(withIdentifier: "UserExistsViewController") {
                self.navigationController?.pushViewController(userExistsVC, animated: true)
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
    
//    func navigateToSignIn() {
//        DispatchQueue.main.async {
//            if let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRegisterViewController") {
//                self.navigationController?.pushViewController(signInVC, animated: true)
//            }
//        }
//    }
    
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
