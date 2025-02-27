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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply border to each text field
        currentPasswordTextField.applyRoundedBorder()
        newPasswordTextField.applyRoundedBorder()
        confirmNewPasswordTextField.applyRoundedBorder()
        
        // Style the save button
        saveButton.layer.cornerRadius = 30
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
    }
}

extension UITextField {
    func applyRoundedBorder() {
        self.layer.cornerRadius = self.frame.height / 2  // Make it perfectly rounded
        self.layer.borderWidth = 1.5                     // Border thickness
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.white             // Ensure background remains white
    }
}
