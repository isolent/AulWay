import UIKit

class PaymentConfirmationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var id: String = ""
    var ticket: Ticket?
    var slot: Slot?
    var passengerCount: Int = 1
    
    var qrCodeBase64: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PaymentConfirmationCell", bundle: nil), forCellReuseIdentifier: "PaymentCell")
        
        fetchPassengerCount()
        fetchTicketDetails(routeId: id)
    }

    func fetchPassengerCount() {
        if let homeVC = presentingViewController as? HomeViewController {
            self.passengerCount = homeVC.passengerCount
            print("👥 Passenger count fetched: \(passengerCount)")
        }
    }

    func fetchTicketDetails(routeId: String) {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No auth token found in UserDefaults")
            return
        }

        let urlString = "http://localhost:8080/api/tickets/\(routeId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        print("📢 Sending request to: \(urlString)")
        print("🔑 Token: \(authToken)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📌 HTTP Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 401 {
                        print("❌ Unauthorized: Invalid token or missing authorization header.")
                    }
                }

                guard let data = data else {
                    print("❌ No data received.")
                    return
                }

                do {
                    let ticketDetails = try JSONDecoder().decode(Ticket.self, from: data)
                    self.ticket = ticketDetails
                    self.qrCodeBase64 = ticketDetails.qrCodeBase64
                    self.fetchRouteDetails(routeId: routeId)
                } catch {
                    print("❌ Failed to parse ticket details: \(error)")
                }
            }
        }
        task.resume()
    }

    func fetchRouteDetails(routeId: String) {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken"), !authToken.isEmpty else {
            print("⚠️ Token not found")
            showAlert(title: "Error", message: "Отсутствует токен авторизации")
            return
        }
        
        let urlString = "http://localhost:8080/api/routes/\(routeId)"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        print("🔗 Fetching route details from: \(urlString)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Response Status Code: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    self.showAlert(title: "Error", message: "No data received.")
                    return
                }
                
                do {
                    let slotDetails = try JSONDecoder().decode(Slot.self, from: data)
                    self.slot = slotDetails
                    print("✅ Route fetched: \(slotDetails)")
                    self.tableView.reloadData()
                } catch {
                    self.showAlert(title: "Error", message: "Не удалось проанализировать детали маршрута.")
                    print("❌ Decoding error: \(error)")
                }
            }
        }
        task.resume()
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ticket != nil && slot != nil) ? 1 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentConfirmationCell
        if let ticket = ticket, let slot = slot {
            cell.configure(with: ticket, slot: slot)
            if let qrCodeBase64 = qrCodeBase64 {
                cell.loadQRCode(from: qrCodeBase64)
            }
        }
        return cell
    }
}
