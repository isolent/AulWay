//
//  ResetPasswordViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/27/24.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var enterCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
        configureTextField(confirmPasswordTextField)
        
        configureButton(sendCodeButton)
        configureButton(enterCodeButton)
        addLeftPadding(to: emailTextField, padding: 14)
        addLeftPadding(to: passwordTextField, padding: 14)
        addLeftPadding(to: confirmPasswordTextField, padding: 14)
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = sendCodeButton.frame.height/2
        textField.clipsToBounds = true
    }
    
    private func configureButton(_ button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = enterCodeButton.frame.height/2
        button.clipsToBounds = true
    }
    
    func addLeftPadding(to textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
}

