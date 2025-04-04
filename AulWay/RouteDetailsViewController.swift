//
//  RouteDetailsViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 08.03.2025.
//

import UIKit

class RouteDetailsViewController: UIViewController {

    @IBOutlet weak var availableSeatNumber: UILabel!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var routeDuration: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet var departureLabels: [UILabel]!
    @IBOutlet var destinationLabels: [UILabel]!
    @IBOutlet weak var departure_location: UILabel!
    
    @IBOutlet weak var destination_location: UILabel!
    var passengerCount: Int = 1
    var selectedSlot: Slot?
    var fromLocation: String = ""
    var toLocation: String = ""
    var travelDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let slot = selectedSlot {
            availableSeatNumber.text = "\(slot.available_seats)"
            priceLabel.text = "\(slot.price) ₸"

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            let start = slot.start_date
            let end = slot.end_date

            startTime.text = timeFormatter.string(from: start)
            endTime.text = timeFormatter.string(from: end)

            let duration = end.timeIntervalSince(start)
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            routeDuration.text = "\(hours)h \(minutes)m"

            if let busNumber = slot.carNumber, !busNumber.isEmpty {
                busNumberLabel.text = busNumber
            } else {
                print("bus number is nil")
                busNumberLabel.text = "Не указан"
            }

            departure_location.text = slot.departure_location
            destination_location.text = slot.destination_location
        }

        departureLabels.forEach { $0.text = fromLocation }
        destinationLabels.forEach { $0.text = toLocation }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateLabel.text = dateFormatter.string(from: travelDate)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapGesture)

        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
    }


    @objc func closeView() {
        dismiss(animated: true, completion: nil)
    }

    @objc func buyButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentProcessViewController") as? PaymentProcessViewController {
            paymentVC.modalPresentationStyle = .automatic
            paymentVC.modalTransitionStyle = .coverVertical
            
            guard let slot = selectedSlot else {
                print("❌ Ошибка: selectedSlot равен nil")
                return
            }
            
            paymentVC.passengerCount = passengerCount
            paymentVC.id = slot.id 
            present(paymentVC, animated: true, completion: nil)
            
            print("✅ Передан ID: \(slot.id)")
        }
    }
}
