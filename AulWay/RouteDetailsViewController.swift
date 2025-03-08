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
    @IBOutlet weak var shareButton: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var routeDuration: UILabel! // New outlet

    @IBOutlet var departureLabels: [UILabel]!
    @IBOutlet var destinationLabels: [UILabel]!

    var selectedSlot: Slot?
    var fromLocation: String = ""
    var toLocation: String = ""
    var travelDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure the selected slot is available
        if let slot = selectedSlot {
            availableSeatNumber.text = "\(slot.availableSeats)"
            priceLabel.text = "\(slot.price) ₸"

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            let start = slot.start_date
            let end = slot.end_date

            startTime.text = timeFormatter.string(from: start)
            endTime.text = timeFormatter.string(from: end)

            // Calculate route duration
            let duration = end.timeIntervalSince(start)
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            routeDuration.text = "\(hours)h \(minutes)m"
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
    }

    @objc func closeView() {
        dismiss(animated: true, completion: nil)
    }
}
