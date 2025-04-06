import UIKit

class PaymentConfirmationCell: UITableViewCell {
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!

    @IBOutlet weak var departureLocation: UILabel!
    @IBOutlet weak var destinationLocation: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(shareTapped))
        shareButton.isUserInteractionEnabled = true
        shareButton.addGestureRecognizer(tap)
    }

    func configure(with ticket: Ticket, slot: Slot?) {
        print("📩 Slot Data: \(String(describing: slot))")

        if let slot = slot {
            routeLabel.text = "\(slot.departure) → \(slot.destination)"
            dateLabel.text = formattedDate(slot.start_date)
            departureTimeLabel.text = formattedTime(slot.start_date)
            arrivalTimeLabel.text = formattedTime(slot.end_date)
            busNumberLabel.text = slot.carNumber?.isEmpty == false ? slot.carNumber : "Не указан"
            orderNumber.text = ticket.order_number
            departureLocation.text = slot.departure_location
            destinationLocation.text = slot.destination_location
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
    
    @IBAction func shareTapped(_ sender: Any) {
        
        guard let parentVC = findViewController() else {
            print("❌ Не удалось найти родительский ViewController")
            return
        }
        
        let pdfData = createPDF(from: self.contentView)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ticket_cell.pdf")
        
        do {
            try pdfData.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = shareButton
            parentVC.present(activityVC, animated: true)
        } catch {
            print("❌ Ошибка при сохранении PDF: \(error)")
        }
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
