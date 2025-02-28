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
        dateFormatter.dateFormat = "yyyy-MM-dd" // Ensure API expects this format
        let dateString = dateFormatter.string(from: travelDate)

        let passengerNum: Int = 1
        let pageNum = 1
        let pageSizeNum = 10

        print("Fetching tickets for Departure: \(fromLocation), Destination: \(toLocation), Date: \(dateString), Passengers: \(passengerNum), Page: \(pageNum), PageSize: \(pageSizeNum)")

        guard let fromEncoded = fromLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let toEncoded = toLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                  print("Encoding failed")
                  return
              }

        let urlString = "http://localhost:8080/routes?departure=\(fromEncoded)&destination=\(toEncoded)&date=\(dateString)&passengers=\(passengerNum)&page=\(pageNum)&pageSize=\(pageSizeNum)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching tickets: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.handleError(message: "Network error. Please try again.")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
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
                decoder.dateDecodingStrategy = .iso8601 // Ensure it decodes dates properly

                let decodedData = try decoder.decode([Slot].self, from: data)

                // Filter results based on selected date (if backend does not filter properly)
                let filteredData = decodedData.filter { slot in
                    let slotDateString = dateFormatter.string(from: slot.start_date)
                    return slotDateString == dateString
                }

                DispatchQueue.main.async {
                    self.slotList = filteredData
                    self.ticketsTableView.reloadData()
                    print("Filtered Slot List Count: \(self.slotList.count)")
                }
            } catch {
                print("Error decoding JSON: \(error)")
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
        dateFormatter.dateFormat = "HH:mm" // 24-hour format

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
    }
}
