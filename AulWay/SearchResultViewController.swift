import UIKit

class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var ticketsTableView: UITableView!
    @IBOutlet weak var Path: UILabel!
    @IBOutlet weak var DateInfo: UILabel!

    var fromLocation: String = ""
    var toLocation: String = ""
    var travelDate: Date = Date()
    var passengerCount: Int = 1
    var routeId: String = ""

    private var allSlots: [Slot] = []
    private var slotList: [Slot] = []
    private var currentPage = 1
    private let pageSize = 10
    private var isLoading = false

    private let prevPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("←", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .regular)
        button.isEnabled = false
        return button
    }()

    private let nextPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("→", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .regular)
        return button
    }()

    private let pageLabel: UILabel = {
        let label = UILabel()
        label.text = "Page 1"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        Path.text = "\(fromLocation) → \(toLocation)"
        DateInfo.text = DateFormatter.localizedString(from: travelDate, dateStyle: .medium, timeStyle: .none)

        ticketsTableView.dataSource = self
        ticketsTableView.delegate = self

        setupPaginationUI()
        fetchTickets()
        
        navigationItem.hidesBackButton = false
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButtonItem


    }

    private func setupPaginationUI() {
        let stackView = UIStackView(arrangedSubviews: [prevPageButton, pageLabel, nextPageButton])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        prevPageButton.addTarget(self, action: #selector(prevPageTapped), for: .touchUpInside)
        nextPageButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)
    }

    @objc private func prevPageTapped() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        updateSlotList(for: currentPage)
    }

    @objc private func nextPageTapped() {
        let totalPages = Int(ceil(Double(allSlots.count) / Double(pageSize)))
        guard currentPage < totalPages else { return }
        currentPage += 1
        updateSlotList(for: currentPage)
    }

    func fetchTickets() {
        guard !isLoading else { return }
        isLoading = true

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: travelDate)

        guard let fromEncoded = fromLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let toEncoded = toLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        let urlString = "http://localhost:8080/api/routes?departure=\(fromEncoded)&destination=\(toEncoded)&date=\(dateString)&passengers=\(passengerCount)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.handleError(message: "Error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode([Slot].self, from: data)

                DispatchQueue.main.async {
                    self.allSlots = decoded
                    self.currentPage = 1
                    self.updateSlotList(for: self.currentPage)
                }

            } catch {
                DispatchQueue.main.async {
                    self.handleError(message: "Decoding error")
                }
            }
        }.resume()
    }

    private func updateSlotList(for page: Int) {
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allSlots.count)

        guard startIndex < allSlots.count else {
            slotList = []
            ticketsTableView.reloadData()
            return
        }

        slotList = Array(allSlots[startIndex..<endIndex])
        ticketsTableView.reloadData()
        updatePaginationUI()
    }

    private func updatePaginationUI() {
        pageLabel.text = "Page \(currentPage)"

        let totalPages = Int(ceil(Double(allSlots.count) / Double(pageSize)))

        prevPageButton.isEnabled = currentPage > 1
        nextPageButton.isEnabled = currentPage < totalPages

        prevPageButton.titleLabel?.font = .systemFont(ofSize: 24, weight: prevPageButton.isEnabled ? .bold : .regular)
        nextPageButton.titleLabel?.font = .systemFont(ofSize: 24, weight: nextPageButton.isEnabled ? .bold : .regular)
    }

    func handleError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slotList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketListTableViewCell", for: indexPath) as! TicketListTableViewCell

        let slot = slotList[indexPath.row]
        cell.configure(with: slot)
        cell.updateFavouriteIcon(isFavourite: slot.isFavourite ?? false)

        cell.onFavouriteTapped = {
            guard let globalIndex = self.allSlots.firstIndex(where: { $0.id == slot.id }) else { return }

            if slot.isFavourite == true {
                self.removeFromFavourites(routeId: slot.id) { success in
                    guard success else { return }
                    self.allSlots[globalIndex].isFavourite = false
                    self.slotList[indexPath.row].isFavourite = false
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            } else {
                self.addToFavourites(routeId: slot.id) { success in
                    guard success else { return }
                    self.allSlots[globalIndex].isFavourite = true
                    self.slotList[indexPath.row].isFavourite = true
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        return cell
    }


    private func addToFavourites(routeId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No user ID or token found")
            completion(false)
            return
        }

        let urlString = "http://localhost:8080/api/users/\(userId)/favorites"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["route_id": routeId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Favorite add error: \(error.localizedDescription)")
                completion(false)
                return
            }
            print("❤️ Route \(routeId) added to favorites.")
            completion(true)
        }.resume()
    }

    private func removeFromFavourites(routeId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No user ID or token found")
            completion(false)
            return
        }

        let urlString = "http://localhost:8080/api/users/\(userId)/favorites/\(routeId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error removing favorite: \(error.localizedDescription)")
                completion(false)
            } else {
                print("🗑️ Removed route \(routeId) from favorites.")
                completion(true)
            }
        }.resume()
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ticketsTableView.deselectRow(at: indexPath, animated: true)

        let selectedSlot = slotList[indexPath.row]
        let globalIndex = allSlots.firstIndex { $0.id == selectedSlot.id }

        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "RouteDetailsViewController") as? RouteDetailsViewController {
            detailsVC.selectedSlot = selectedSlot
            detailsVC.fromLocation = fromLocation
            detailsVC.toLocation = toLocation
            detailsVC.travelDate = travelDate
            detailsVC.passengerCount = passengerCount
            present(detailsVC, animated: true)
        }
    }
    
    private func formattedTimeRange(for slot: Slot) -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return "\(df.string(from: slot.start_date)) - \(df.string(from: slot.end_date))"
    }

    private func formattedDuration(for slot: Slot) -> String {
        let df = DateComponentsFormatter()
        df.unitsStyle = .abbreviated
        df.allowedUnits = [.hour, .minute]
        return df.string(from: slot.start_date, to: slot.end_date) ?? "N/A"
    }
    
    @objc func backButtonTapped() {
        tabBarController?.selectedIndex = 0
        navigationController?.popToRootViewController(animated: true)
    }
}
