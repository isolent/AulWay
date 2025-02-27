//
//  PrivacySecurityViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 24.02.2025.
//

import UIKit

class PrivacySecurityViewController: UIViewController {

    @IBOutlet weak var infoText: UITextView!

    override func viewDidLoad() {
            super.viewDidLoad()
        infoText.layer.cornerRadius = 20
        infoText.clipsToBounds = true 
        }
    
}
