//
//  UserExistsViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 07.03.2025.
//

import UIKit

class UserExistsViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func signUpButtonTapped(_ sender: Any) {
        if let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") {
            signUpVC.modalPresentationStyle = .fullScreen
            present(signUpVC, animated: true, completion: nil)
        }
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") {
            signInVC.modalPresentationStyle = .fullScreen
            present(signInVC, animated: true, completion: nil)
        }
    }

}
