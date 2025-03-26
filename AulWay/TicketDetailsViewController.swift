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
    var ticketId: String = ""
    var userId: String = ""

    @IBOutlet weak var firstStackView: UIStackView!
    
    @IBOutlet weak var secondStackView: UIStackView!
    
    @IBOutlet weak var thirdStackView: UIStackView!
    @IBOutlet weak var fourthStackView: UIStackView!
    
    @IBOutlet weak var mainStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContainers()
        fetchTicketDetails()
    }

    private func fetchTicketDetails() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("❌ No auth token found")
            return
        }

        let urlString = "http://localhost:8080/api/tickets/users/\(userId)/\(ticketId)"
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

        let urlString = "http://localhost:8080/api/routes/\(routeId)"
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

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    self.dateLabel.text = dateFormatter.string(from: slot.start_date)
                }
            } catch {
                print("❌ Route decoding error: \(error)")
            }
        }.resume()
    }

    private func populateTicketUI(ticket: Ticket) {
        priceLabel.text = "\(ticket.price) ₸"
        statusLabel.text = ticket.payment_status.capitalized
        qrImageView.backgroundColor = .white

        if let qrImage = generateQRCode(from: ticket.qr_code) {
            qrImageView.image = qrImage
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

            let transform = CGAffineTransform(scaleX: 12, y: 12) // увеличил

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
        let containers = [firstStackView, secondStackView, thirdStackView, fourthStackView]
        
        for container in containers {
            container?.translatesAutoresizingMaskIntoConstraints = false
            container?.layer.cornerRadius = 16
            container?.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
            container?.clipsToBounds = true
            
            container?.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            
            if let stackView = container?.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
                stackView.isLayoutMarginsRelativeArrangement = true
                stackView.layoutMargins = container!.layoutMargins
            }
        }
    }


}
