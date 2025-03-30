//
//  FavouritesListTableViewCell.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 30.03.2025.
//

import UIKit

class FavouritesListTableViewCell: UITableViewCell {
    @IBOutlet weak var duration: UILabel!
       @IBOutlet weak var time: UILabel!
       @IBOutlet weak var price: UILabel!
       @IBOutlet weak var route: UILabel!

       override func awakeFromNib() {
           super.awakeFromNib()
           configureStyle()
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
       }

       private func configureStyle() {
           contentView.layer.cornerRadius = 20
           contentView.layer.masksToBounds = true
           contentView.layer.borderWidth = 1
           contentView.layer.borderColor = UIColor.lightGray.cgColor
           contentView.backgroundColor = UIColor(red: 0.49, green: 0.51, blue: 0.49, alpha: 1.0)
       }

       func configure(with slot: Slot) {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "HH:mm"

           let timeString = "\(dateFormatter.string(from: slot.start_date)) - \(dateFormatter.string(from: slot.end_date))"

           let durationFormatter = DateComponentsFormatter()
           durationFormatter.unitsStyle = .abbreviated
           durationFormatter.allowedUnits = [.hour, .minute]
           let travelTime = durationFormatter.string(from: slot.start_date, to: slot.end_date) ?? "N/A"

           self.route.text = "\(slot.departure) → \(slot.destination)"
           self.duration.text = "\(travelTime)"
           self.time.text = timeString
           self.price.text = "\(slot.price) ₸"
       }}
