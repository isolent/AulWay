//
//  SearchResultViewController.swift
//  AulWay
//

import UIKit

class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var ticketsTableView: UITableView!
    @IBOutlet weak var Path: UILabel!
    @IBOutlet weak var DateInfo: UILabel!

    var fromLocation: String = ""
    var toLocation: String = ""
    var travelDate: Date = Date()
    var slotList: [Slot] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        Path.text = "\(fromLocation) → \(toLocation)"
        DateInfo.text = DateFormatter.localizedString(from: travelDate, dateStyle: .medium, timeStyle: .none)

        ticketsTableView.dataSource = self
        ticketsTableView.delegate = self

        fetchTickets()
    }

    func fetchTickets() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: travelDate)

        let passengerNum: Int = 1
        let pageNum = 1
        let pageSizeNum = 10

        print("🚀 Fetching tickets for: Departure: \(fromLocation), Destination: \(toLocation), Date: \(dateString), Passengers: \(passengerNum)")

        guard let fromEncoded = fromLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let toEncoded = toLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("⚠️ Encoding failed")
            return
        }

        let urlString = "http://localhost:8080/api/routes?departure=\(fromEncoded)&destination=\(toEncoded)&date=\(dateString)&passengers=\(passengerNum)&page=\(pageNum)&pageSize=\(pageSizeNum)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Authorization Token: Bearer \(token)")
        } else {
            print("⚠️ No auth token found! API might return 401 Unauthorized.")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.handleError(message: "Network error. Please try again.")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response from server")
                return
            }

            print("📡 Server Response Status Code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 401 {
                print("⚠️ Unauthorized (401) - Token might be missing or expired.")
                DispatchQueue.main.async {
                    self.handleError(message: "Session expired. Please log in again.")
                }
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                print("❌ Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.handleError(message: "Server error. Please try again later.")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.handleError(message: "No data received.")
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let decodedData = try decoder.decode([Slot].self, from: data)

                let filteredData = decodedData.filter { slot in
                    let slotDateString = dateFormatter.string(from: slot.start_date)
                    return slotDateString == dateString
                }

                DispatchQueue.main.async {
                    self.slotList = filteredData
                    self.ticketsTableView.reloadData()
                    print("✅ Tickets Loaded: \(self.slotList.count)")
                }
            } catch {
                print("❌ JSON Decoding error: \(error)")
                DispatchQueue.main.async {
                    self.handleError(message: "Invalid data received from server.")
                }
            }
        }

        task.resume()
    }

    private func navigateToResultNFViewController() {
        if let resultNFVC = storyboard?.instantiateViewController(withIdentifier: "ResultNFViewController") {
            resultNFVC.modalPresentationStyle = .fullScreen
            present(resultNFVC, animated: true, completion: nil)
        }
    }

    func handleError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slotList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketListTableViewCell", for: indexPath) as! TicketListTableViewCell

        let slot = slotList[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let timeString = "\(dateFormatter.string(from: slot.start_date)) - \(dateFormatter.string(from: slot.end_date))"

        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute]
        let travelTime = durationFormatter.string(from: slot.start_date, to: slot.end_date) ?? "N/A"

        cell.duration.text = "\(travelTime) "
        cell.price.text = "\(slot.price) ₸"
        cell.time.text = "\(timeString)"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ticketsTableView.deselectRow(at: indexPath, animated: true)

        let selectedSlot = slotList[indexPath.row]

        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "RouteDetailsViewController") as? RouteDetailsViewController {
            detailsVC.modalPresentationStyle = .automatic
            detailsVC.modalTransitionStyle = .coverVertical

            detailsVC.selectedSlot = selectedSlot
            detailsVC.fromLocation = fromLocation
            detailsVC.toLocation = toLocation
            detailsVC.travelDate = travelDate

            present(detailsVC, animated: true, completion: nil)
        }
    }

}
