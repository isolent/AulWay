import UIKit

class PaymentConfirmationCell: UITableViewCell {
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with ticket: Ticket, slot: Slot?) {
        print("📩 Slot Data: \(String(describing: slot))")

        if let slot = slot {
            routeLabel.text = "\(slot.departure) → \(slot.destination)"
            dateLabel.text = formattedDate(slot.start_date)
            departureTimeLabel.text = formattedTime(slot.start_date)
            arrivalTimeLabel.text = formattedTime(slot.end_date)
            busNumberLabel.text = slot.carNumber?.isEmpty == false ? slot.carNumber : "Не указан"
        } else {
            routeLabel.text = "Маршрут не найден"
            dateLabel.text = "Дата не указана"
            departureTimeLabel.text = "—"
            arrivalTimeLabel.text = "—"
            busNumberLabel.text = "Не указан"
        }


        if !ticket.qr_code.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = Data(base64Encoded: ticket.qr_code, options: .ignoreUnknownCharacters),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.qrImage.image = image
                    }
                } else {
                    print("❌ Не удалось декодировать QR код из Base64")
                }
            }
        } else {
            qrImage.image = nil
        }

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
