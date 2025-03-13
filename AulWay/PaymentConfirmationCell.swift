//
//  TableViewCell.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 13.03.2025.
//

import UIKit

class PaymentConfirmationCell: UITableViewCell {
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    

    func configure(with ticket: Ticket, slot: Slot) {
        routeLabel.text = "\(slot.departure) → \(slot.destination)"
        dateLabel.text = formattedDate(slot.start_date)
        departureTimeLabel.text = formattedTime(slot.start_date)
        arrivalTimeLabel.text = formattedTime(slot.end_date)
        busNumberLabel.text = slot.carNumber ?? "N/A"
        

    }

       func loadQRCode(from urlString: String) {
           guard let url = URL(string: urlString) else {
               print("❌ Invalid QR code URL")
               return
           }
           fetchQRCode(from: url)
       }

       private func fetchQRCode(from url: URL) {
           let task = URLSession.shared.dataTask(with: url) { data, response, error in
               DispatchQueue.main.async {
                   if let error = error {
                       print("❌ Error loading QR code: \(error.localizedDescription)")
                       return
                   }
                   if let data = data, let image = UIImage(data: data) {
                       self.qrImage.image = image
                   } else {
                       print("❌ Failed to convert data into image")
                   }
               }
           }
           task.resume()
       }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
