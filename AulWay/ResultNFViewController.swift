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

        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButtonItem


    }

    @objc func backButtonTapped() {
        tabBarController?.selectedIndex = 0
        navigationController?.popToRootViewController(animated: true)
    }
    
}
