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
        let slot = ticket.slot // Extract Slot from Ticket
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"

        self.route.text = "\(slot.departure) → \(slot.destinatoin)"
        self.duration.text = "\(dateFormatter.string(from: slot.start_date)) - \(dateFormatter.string(from: slot.end_date))"
        self.price.text = "\(slot.price) ₸"
    }
}

