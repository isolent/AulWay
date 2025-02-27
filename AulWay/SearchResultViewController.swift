//
//  TicketListViewController.swift
//  AulWay
//

//

import UIKit

class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var ticketsTableView: UITableView!
    @IBOutlet weak var Path: UILabel!
    @IBOutlet weak var DateInfo: UILabel!

    var fromLocation: String = ""
    var toLocation: String = ""
    var travelDate: Date = Date()
    var passengerCount: Int = 1
    var slotList: [Slot] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        Path.text = "\(fromLocation) → \(toLocation)"
        DateInfo.text = DateFormatter.localizedString(from: travelDate, dateStyle: .medium, timeStyle: .none)

        ticketsTableView.dataSource = self
        ticketsTableView.delegate = self

        fetchTickets()  // Fetch real data from the server
    }

    func fetchTickets() {
        // Example API Call (Replace with your actual API request logic)
        let urlString = "https://your-api.com/tickets?from=\(fromLocation)&to=\(toLocation)&date=\(travelDate)"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching tickets: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }

            do {
                let decodedData = try JSONDecoder().decode([Slot].self, from: data)
                DispatchQueue.main.async {
                    self.slotList = decodedData
                    self.ticketsTableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slotList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketListTableViewCell", for: indexPath) as! TicketListTableViewCell

        let slot = slotList[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"

        cell.duration.text = "\(dateFormatter.string(from: slot.start_date)) - \(dateFormatter.string(from: slot.end_date))"
        cell.time.text = "\(slot.departure) → \(slot.destinatoin)"
        cell.price.text = "\(slot.price) ₸"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ticketsTableView.deselectRow(at: indexPath, animated: true)
    }
}
