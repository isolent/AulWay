//
//  ResultNFViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 28.02.2025.
//

import UIKit

class ResultNFViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add a Back Button
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}
