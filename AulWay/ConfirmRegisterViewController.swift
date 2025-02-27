//
//  ConfirmRegisterViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 25.02.2025.
//

import UIKit

class ConfirmRegisterViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()
    }

        @IBAction func signInButtonTapped(_ sender: UIButton) {
            if let signInVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") {
                        navigationController?.pushViewController(signInVC, animated: true)
                    }
        }
}
