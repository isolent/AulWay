//
//  SignInViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/25/24.
//



//  SignInViewController.swift
//  AulWay
//
//  Created by Tomiris on 25.12.2024.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
   // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
        
        configureButton(signInButton)
        
        addLeftPadding(to: emailTextField, padding: 14)
        addLeftPadding(to: passwordTextField, padding: 14)
        
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("⚠️ Please enter both email and password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Sign-in failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                print("❌ User not found")
                return
            }
            
            print("✅ Successfully signed in! User ID: \(user.uid), Email: \(user.email ?? "No Email")")

            // Fetch user authentication token
            user.getIDToken { token, error in
                if let error = error {
                    print("❌ Failed to get auth token: \(error.localizedDescription)")
                } else if let token = token {
                    print("🔑 Auth Token: \(token)")
                }
            }
            
            // Navigate to HomeViewController
            DispatchQueue.main.async {
                if let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "Tickets") {
                    homeVC.modalPresentationStyle = .fullScreen
                    self.present(homeVC, animated: true, completion: nil)
                }
            }
        }
    }
    
//    @IBAction func toHome(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let tabBarController = storyboard.instantiateViewController(identifier: "Tickets") as? UITabBarController {
//            UIApplication.shared.windows.first?.rootViewController = tabBarController
//            UIApplication.shared.windows.first?.makeKeyAndVisible()
//        }
//    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = emailTextField.frame.height/2
        textField.clipsToBounds = true
    }
    
    private func configureButton(_ button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = signInButton.frame.height/2
        button.clipsToBounds = true
    }
    
    func addLeftPadding(to textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
}
