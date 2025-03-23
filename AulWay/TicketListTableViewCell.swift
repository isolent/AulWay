//
//  TicketListTableViewCell.swift
//  AulWay
//
//

import UIKit

class TicketListTableViewCell: UITableViewCell {

    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var route: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    private func configureCell() {
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.backgroundColor = #colorLiteral(red: 0.4941176471, green: 0.5137254902, blue: 0.4901960784, alpha: 1)
        self.contentView.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
    }
    
    func configure(with ticket: Ticket) {
        let slot = ticket.slot
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" 

        let timeString = "\(dateFormatter.string(from: slot.start_date)) - \(dateFormatter.string(from: slot.end_date))"

        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated // "1h 30m"
        durationFormatter.allowedUnits = [.hour, .minute]
        let travelTime = durationFormatter.string(from: slot.start_date, to: slot.end_date) ?? "N/A"

        self.route.text = "\(slot.departure) → \(slot.destination)"
        self.duration.text = "\(travelTime) (\(timeString))"
        self.price.text = "\(slot.price) ₸"
    }
}
