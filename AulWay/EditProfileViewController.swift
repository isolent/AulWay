//
//  EditProfileViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 26.02.2025.
//

import UIKit

class EditProfileViewController: UIViewController {
    
   
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadUserData()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
            saveUserData()
            showAlert()
        }

        private func saveUserData() {
            let defaults = UserDefaults.standard
            defaults.setValue(firstNameTextField.text, forKey: "firstName")
            defaults.setValue(lastNameTextField.text, forKey: "lastName")
            defaults.setValue(phoneNumberTextField.text, forKey: "phoneNumber")
            defaults.setValue(emailTextField.text, forKey: "email")
        }

        private func loadUserData() {
            let defaults = UserDefaults.standard
            firstNameTextField.text = defaults.string(forKey: "firstName")
            lastNameTextField.text = defaults.string(forKey: "lastName")
            phoneNumberTextField.text = defaults.string(forKey: "phoneNumber")
            emailTextField.text = defaults.string(forKey: "email")
        }

        private func showAlert() {
            let alert = UIAlertController(title: "Success", message: "Your data has been saved!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigateToHomePage()
            }))
            present(alert, animated: true, completion: nil)
        }

        private func navigateToHomePage() {
            if let homeVC = storyboard?.instantiateViewController(withIdentifier: "Tickets") {
                homeVC.modalPresentationStyle = .fullScreen
                present(homeVC, animated: true, completion: nil)
            }
        }}
