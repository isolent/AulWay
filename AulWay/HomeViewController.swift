//
//  HomeViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/26/24.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var From: UITextField!
    @IBOutlet weak var Date: UIDatePicker!
    @IBOutlet weak var PassengerInfo: UILabel!
    @IBOutlet weak var To: UITextField!
    @IBAction func FindTicket(_ sender: UIButton) {
    }
    
    var passengerCount: Int = 1 {
        didSet {
            PassengerInfo.text = "\(passengerCount) passenger"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PassengerInfo.text = "\(passengerCount) passenger"
        
        PassengerInfo.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        PassengerInfo.layer.cornerRadius = PassengerInfo.frame.height / 2
        PassengerInfo.layer.masksToBounds = true
        
        From.layer.cornerRadius = From.frame.height / 2
        From.layer.masksToBounds = true
        To.layer.cornerRadius = To.frame.height / 2
        To.layer.masksToBounds = true
    }
    
    
    @IBAction func increasePassengerCount(_ sender: UIButton) {
        passengerCount += 1
    }
    

    @IBAction func decreasePassengerCount(_ sender: UIButton) {
        if passengerCount > 1 { // Prevent going below 1
            passengerCount -= 1
        }
    }
    

}
