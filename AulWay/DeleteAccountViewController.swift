//
//  DeleteAccountViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 24.02.2025.
//

import UIKit

class DeleteAccountViewController: UIViewController {

    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var keepAccountButton: UIButton!
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        
        if let window = UIApplication.shared.windows.first {
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let initialViewController = storyboard.instantiateInitialViewController()
               window.rootViewController = initialViewController
               window.makeKeyAndVisible()
           }
    }
    
    @IBAction func keepAccountButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
