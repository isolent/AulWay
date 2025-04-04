//
//  TicketDetailsViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 26.03.2025.
//

import UIKit


class TicketDetailsViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var shareButton: UIImageView!
    @IBOutlet weak var orderNumberLabel: UILabel!
    
    @IBOutlet weak var departureLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!

    var ticketId: String = ""
    var userId: String = ""
    var ticket: Ticket?
    var startDate: Date?


    @IBOutlet weak var sixthStackView: UIStackView!
    @IBOutlet weak var fifthStackView: UIStackView!
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var secondStackView: UIStackView!
    @IBOutlet weak var thirdStackView: UIStackView!
    @IBOutlet weak var fourthStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContainers()
        fetchTicketDetails()
        shareButton.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(shareTapped))
        shareButton.addGestureRecognizer(tap)

    }

    private func fetchTicketDetails() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("❌ No auth token found")
            return
        }

        let urlString = "\(BASE_URL)/api/tickets/users/\(userId)/\(ticketId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid ticket details URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching ticket: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No ticket data received")
                return
            }
            print("Ticket id: \(self.ticketId)")
            do {
                let ticket = try JSONDecoder().decode(Ticket.self, from: data)
                DispatchQueue.main.async {
                    self.populateTicketUI(ticket: ticket)
                }
                self.fetchRouteDetails(routeId: ticket.route_id!)
            } catch {
                print("❌ Ticket decoding failed: \(error)")
            }
        }.resume()
    }

    private func fetchRouteDetails(routeId: String) {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else { return }

        let urlString = "\(BASE_URL)/api/routes/\(routeId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid route URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching route: \(error)")
                return
            }

            guard let data = data else {
                print("❌ No route data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(Slot.dateFormatter)
                let slot = try decoder.decode(Slot.self, from: data)

                DispatchQueue.main.async {
                    self.departureLabel.text = self.formattedTime(slot.start_date)
                    self.arrivalLabel.text = self.formattedTime(slot.end_date)
                    self.pathLabel.text = "\(slot.departure) - \(slot.destination)"
                    self.busNumberLabel.text = slot.carNumber ?? "–"
                    self.departureLocationLabel.text = slot.departure_location
                    self.destinationLocationLabel.text = slot.destination_location

                    

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    self.dateLabel.text = dateFormatter.string(from: slot.start_date)
                }
            } catch {
                print("❌ Route decoding error: \(error)")
            }
        }.resume()
    }
    
    private func cancelTicket() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            showAlert(title: "Ошибка", message: "Токен не найден")
            return
        }

        let urlString = "\(BASE_URL)/api/tickets/users/\(userId)/\(ticketId)/cancel"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Ошибка", message: "Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Ошибка", message: "Ошибка сети: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(title: "Ошибка", message: "Некорректный ответ сервера.")
                    return
                }

                if httpResponse.statusCode == 200 {
                    self.showAlert(title: "Успешно", message: "Билет отменён.") {
                        self.navigateToUserTickets()
                        NotificationCenter.default.post(name:       NSNotification.Name("TicketCancelled"), object: nil)

                    }
                } else {
                    self.showAlert(title: "Ошибка", message: "Не удалось отменить билет.")
                }
            }
        }.resume()
    }


    private func populateTicketUI(ticket: Ticket) {
        priceLabel.text = "\(ticket.price) ₸"
        statusLabel.text = ticket.payment_status.capitalized
        orderNumberLabel.text = "\(ticket.order_number)"

        
//        print("📦 Order Number: \(ticket.order_number)")

//        qrImageView.backgroundColor = .white

        if !ticket.qr_code.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = Data(base64Encoded: ticket.qr_code, options: .ignoreUnknownCharacters),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.qrImageView.image = image
                    }
                } else {
                    print("❌ Не удалось декодировать QR код из Base64")
                }
            }
        } else {
            qrImageView.image = nil
        }
    }


    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")

            let transform = CGAffineTransform(scaleX: 12, y: 12)

            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }

    private func setupContainers() {
        let containers = [firstStackView, secondStackView, thirdStackView, fourthStackView, fifthStackView, sixthStackView]

        for container in containers {
            container?.translatesAutoresizingMaskIntoConstraints = false
            container?.layer.cornerRadius = 10
            container?.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
            container?.clipsToBounds = true
            
            container?.isLayoutMarginsRelativeArrangement = true
            container?.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
    
    func createPDF(from view: UIView) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: view.bounds)
        return pdfRenderer.pdfData { context in
            context.beginPage()
            view.layer.render(in: context.cgContext)
        }
    }
    
    @IBAction func cancelTicketTapped(_ sender: UIButton) {
        guard let ticket = ticket else { return }

        if ticket.slot.start_date < Date() {
            showAlert(title: "Нельзя отменить", message: "Вы не можете отменить прошедший билет.")
            return
        }

        let alert = UIAlertController(
            title: "Отмена билета",
            message: "Вы уверены, что хотите отменить билет?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отменить", style: .destructive) { _ in
            self.cancelTicket()
        })

        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))

        present(alert, animated: true)
    }


    @objc private func shareTapped() {
        
        let pdfData = createPDF(from: mainStackView)

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ticket.pdf")
        do {
            try pdfData.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = shareButton
            present(activityVC, animated: true)
        } catch {
            print("❌ Failed to write PDF: \(error)")
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func navigateToUserTickets() {
        if let nav = self.navigationController {
            for vc in nav.viewControllers {
                if vc is UserTicketsViewController {
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let userTicketsVC = storyboard.instantiateViewController(withIdentifier: "UserTicketsViewController") as? UserTicketsViewController {
                nav.setViewControllers([userTicketsVC], animated: true)
            }
        }
    }
}
