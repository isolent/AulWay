//
//  SignUpViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 27.12.2024.
//

import UIKit
import FirebaseAuth 



class SignUpViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confPassTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
        configureTextField(confPassTextFiled)
        
        configureButton(signUpButton)
        
        addLeftPadding(to: emailTextField, padding: 14)
        addLeftPadding(to: passwordTextField, padding: 14)
        addLeftPadding(to: confPassTextFiled, padding: 14)
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(identifier: "Tickets") as? UITabBarController {
            UIApplication.shared.windows.first?.rootViewController = tabBarController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = emailTextField.frame.height/2
        textField.clipsToBounds = true
    }
    
    private func configureButton(_ button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = signInButton.frame.height/1.3
        button.clipsToBounds = true
    }
    
    func addLeftPadding(to textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    @IBAction func signUpTapped(_ sender: UIButton){
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("⚠️ Please enter both email and password")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Sign-up failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                print("❌ User not found after sign-up")
                return
            }
            
            print("✅ Successfully signed up! User ID: \(user.uid)")
            
            user.getIDToken { token, error in
                if let error = error {
                    print("❌ Failed to get token: \(error.localizedDescription)")
                } else if let token = token {
                    print("🔑 Auth Token: \(token)")
                }
            }
            
            DispatchQueue.main.async {
                self.navigateToSignIn()
            }
        }
    }
    
    
    func navigateToSignIn() {
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "ConfirmRegisterViewController") {
            navigationController?.pushViewController(signInVC, animated: true)
        }
    }
}
