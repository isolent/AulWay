//
//  PaymentFailedViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 31.03.2025.
//

import UIKit

class PaymentFailedViewController: UIViewController {
    var id: String = ""
    var passengerCount: Int = 1

    @IBOutlet weak var tryAgainButton: UIButton!

    @IBAction func tryAgainTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
