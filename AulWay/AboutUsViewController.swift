//
//  AboutUsViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 24.02.2025.
//

import UIKit

class AboutUsViewController: UIViewController {

    override func viewDidLoad() {
            super.viewDidLoad()
        textLabel.layer.cornerRadius = 20
        textLabel.clipsToBounds = true // Ensure content stays within rounded corners
        }
    
    @IBOutlet weak var textLabel: UITextView!
    
    

}
