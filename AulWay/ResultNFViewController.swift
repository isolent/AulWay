//
//  ResultNFViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 28.02.2025.
//

import UIKit

class ResultNFViewController: UIViewController {
    
    var path: String = ""
    var dateInfo: String = ""
    
    
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pathLabel.text = path
        dateLabel.text = dateInfo

        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}
