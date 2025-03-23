//
//  PaymentConfirmationViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 10.03.2025.
//

import UIKit

class PaymentConfirmationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tickets: [Ticket] = []
    var slots: [Slot] = []
    var passengerCount: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchPassengerCount()
        loadTicketDetails()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func fetchPassengerCount() {
        if let homeVC = presentingViewController as? HomeViewController {
            passengerCount = homeVC.passengerCount
            print("👥 Passenger count: \(passengerCount)")
        }
    }
    
    private func loadTicketDetails() {
        guard !tickets.isEmpty else {
            showAlert(title: "Ошибка", message: "Данные билетов отсутствуют.")
            return
        }

        let routeIds = Set(tickets.compactMap { $0.route_id })
        
        for routeId in routeIds {
            print("🛣 Fetching route for ID: \(routeId)")
            fetchSlotDetails(routeId: routeId)
        }
    }

    private func fetchSlotDetails(routeId: String) {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken"), !authToken.isEmpty else {
            print("❌ Ошибка: нет authToken")
            return
        }

        let urlString = "http://localhost:8080/api/routes/\(routeId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received for slot details")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("🔄 HTTP Status Code: \(httpResponse.statusCode)")
            }

            print("📩 Slot API Response: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(Slot.dateFormatter) 
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let slot = try decoder.decode(Slot.self, from: data)

                DispatchQueue.main.async {
                    self.slots.append(slot)
                    self.tableView.reloadData()
                }
            } catch let DecodingError.keyNotFound(key, context) {
                print("❌ Missing key: \(key.stringValue) in \(context.codingPath)")
            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }.resume()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func findSlot(for ticket: Ticket) -> Slot? {
        return slots.first { $0.id == ticket.route_id }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentConfirmationCell", for: indexPath) as! PaymentConfirmationCell
        let ticket = tickets[indexPath.row]
        
        let slotForTicket = findSlot(for: ticket)

        cell.configure(with: ticket, slot: slotForTicket)

        return cell
    }
}
