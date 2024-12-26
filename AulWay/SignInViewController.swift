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

class SignInViewController: UIViewController {
   // MARK: - Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func toHome(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(identifier: "Tickets") as? UITabBarController {
            UIApplication.shared.windows.first?.rootViewController = tabBarController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
