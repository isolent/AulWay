//
//  SignUpViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/26/24.
//

import UIKit


class SignUpViewController: UIViewController {
   // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(identifier: "Tickets") as? UITabBarController {
            UIApplication.shared.windows.first?.rootViewController = tabBarController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
