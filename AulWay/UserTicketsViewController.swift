import UIKit

class UserTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    enum TicketType {
        case past
        case upcoming
    }

    var currentTicketType: TicketType = .upcoming
    var allPastTickets: [Ticket] = []
    var allUpcomingTickets: [Ticket] = []
    var displayedTickets: [Ticket] = []

    private var currentPage = 1
    private let pageSize = 10

    @IBOutlet weak var tickets: UITableView!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var pastButton: UIButton!

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

    private let noTicketsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir Next", size: 24)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.isHidden = true
        return label
    }()

    private let findTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Найти билет", for: .normal)
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.85)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 20
        button.isHidden = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tickets.delegate = self
        tickets.dataSource = self
        styleButtons()
        setupPaginationUI()
        setupEmptyStateUI()
        fetchTickets()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTicketsAfterCancel), name: NSNotification.Name("TicketCancelled"), object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTickets()
    }
    
    @objc private func reloadTicketsAfterCancel() {
        fetchTickets()
    }


    private func setupPaginationUI() {
        let stackView = UIStackView(arrangedSubviews: [prevPageButton, pageLabel, nextPageButton])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        prevPageButton.addTarget(self, action: #selector(prevPageTapped), for: .touchUpInside)
        nextPageButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)
    }

    private func setupEmptyStateUI() {
        view.addSubview(noTicketsLabel)
        view.addSubview(findTicketButton)

        noTicketsLabel.translatesAutoresizingMaskIntoConstraints = false
        findTicketButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            noTicketsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            noTicketsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            noTicketsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),

            findTicketButton.topAnchor.constraint(equalTo: noTicketsLabel.bottomAnchor, constant: 20),
            findTicketButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            findTicketButton.widthAnchor.constraint(equalToConstant: 330),
            findTicketButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        findTicketButton.addTarget(self, action: #selector(findTicketTapped), for: .touchUpInside)
    }

    @objc private func findTicketTapped() {
        tabBarController?.selectedIndex = 0
    }

    @objc private func prevPageTapped() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        updateDisplayedTickets()
    }

    @objc private func nextPageTapped() {
        let allTickets = currentTicketType == .past ? allPastTickets : allUpcomingTickets
        let totalPages = Int(ceil(Double(allTickets.count) / Double(pageSize)))
        guard currentPage < totalPages else { return }
        currentPage += 1
        updateDisplayedTickets()
    }

    private func updateDisplayedTickets() {
        let allTickets = currentTicketType == .past ? allPastTickets : allUpcomingTickets
        let startIndex = (currentPage - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allTickets.count)

        if startIndex < endIndex {
            displayedTickets = Array(allTickets[startIndex..<endIndex])
        } else {
            displayedTickets = []
        }

        tickets.isHidden = displayedTickets.isEmpty
        pageLabel.isHidden = displayedTickets.isEmpty
        prevPageButton.isHidden = displayedTickets.isEmpty
        nextPageButton.isHidden = displayedTickets.isEmpty

        noTicketsLabel.isHidden = !displayedTickets.isEmpty
        findTicketButton.isHidden = !displayedTickets.isEmpty

        if displayedTickets.isEmpty {
            noTicketsLabel.text = currentTicketType == .upcoming
                ? "У вас нет никаких предстоящих поездок"
                : "У вас нет никаких прошлых поездок"
        }

        tickets.reloadData()
        updatePaginationUI()
    }
    private func updatePaginationUI() {
        pageLabel.text = "Page \(currentPage)"
        let allTickets = currentTicketType == .past ? allPastTickets : allUpcomingTickets
        let totalPages = Int(ceil(Double(allTickets.count) / Double(pageSize)))

        prevPageButton.isEnabled = currentPage > 1
        nextPageButton.isEnabled = currentPage < totalPages

        prevPageButton.titleLabel?.font = .systemFont(ofSize: 24, weight: prevPageButton.isEnabled ? .bold : .regular)
        nextPageButton.titleLabel?.font = .systemFont(ofSize: 24, weight: nextPageButton.isEnabled ? .bold : .regular)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! UserTicketsTableViewCell

        let ticket = displayedTickets[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        cell.Date.text = dateFormatter.string(from: ticket.slot.start_date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        cell.Time.text = "\(timeFormatter.string(from: ticket.slot.start_date)) - \(timeFormatter.string(from: ticket.slot.end_date))"

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: ticket.slot.start_date, to: ticket.slot.end_date)

        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        cell.Duration.text = "\(hours)ч \(minutes)м"


        cell.Path.text = "\(ticket.slot.departure) - \(ticket.slot.destination)"
        cell.Status.text = "Paid"
        cell.CarNumber.text = ticket.slot.carNumber ?? "-"


        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ticket = displayedTickets[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let ticketDetailsVC = storyboard.instantiateViewController(withIdentifier: "TicketDetailsViewController") as? TicketDetailsViewController {
            ticketDetailsVC.ticketId = ticket.id
            ticketDetailsVC.userId = ticket.user_id
            ticketDetailsVC.ticket = ticket
            self.navigationController?.pushViewController(ticketDetailsVC, animated: true)
        }
    }

    @IBAction func switchTicketType(_ sender: UIButton) {
        currentTicketType = sender == upcomingButton ? .upcoming : .past
            updateButtonStyles()
        currentPage = 1
        updateDisplayedTickets()
    }

    private func styleButtons() {
        pastButton.layer.cornerRadius = pastButton.frame.height / 2
        upcomingButton.layer.cornerRadius = upcomingButton.frame.height / 2
        updateButtonStyles()
    }

    private func updateButtonStyles() {
        let activeColor = UIColor.lightGray
        let inactiveColor = UIColor(red: 0.49, green: 0.51, blue: 0.49, alpha: 1.0)

        if currentTicketType == .upcoming {
            upcomingButton.backgroundColor = activeColor
            upcomingButton.setTitleColor(.black, for: .normal)
            pastButton.backgroundColor = inactiveColor
            pastButton.setTitleColor(.white, for: .normal)
        } else {
            pastButton.backgroundColor = activeColor
            pastButton.setTitleColor(.black, for: .normal)
            upcomingButton.backgroundColor = inactiveColor
            upcomingButton.setTitleColor(.white, for: .normal)
        }
    }

    private func fetchTickets() {
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
              let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("❌ Не удалось получить токен или user_id")
            return
        }

        var upcomingFetched = false
        var pastFetched = false

        let checkAndHandle = {
            if upcomingFetched && pastFetched {
                self.updateDisplayedTickets()
            }
        }

        fetchTickets(for: .upcoming, userId: userId, token: token) {
            DispatchQueue.main.async {
                upcomingFetched = true
                checkAndHandle()
            }
        }

        fetchTickets(for: .past, userId: userId, token: token) {
            DispatchQueue.main.async {
                pastFetched = true
                checkAndHandle()
            }
        }
    }

    private func fetchTickets(for type: TicketType, userId: String, token: String, completion: @escaping () -> Void) {
        let typeStr = type == .past ? "past" : "upcoming"
        let urlString = "\(BASE_URL)/api/tickets/users/\(userId)?type=\(typeStr)"
        guard let url = URL(string: urlString) else {
            completion()
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion()
                return
            }

            do {
                var fetchedTickets = try JSONDecoder().decode([Ticket].self, from: data)
                
                fetchedTickets = fetchedTickets.filter {
                    $0.status.lowercased() != "cancelled" &&
                    $0.payment_status.lowercased() != "refunded"
                }
                
                let group = DispatchGroup()

                for i in 0..<fetchedTickets.count {
                    if fetchedTickets[i].slot.departure == "Unknown" {
                        group.enter()
                        self.fetchSlot(for: fetchedTickets[i].route_id ?? "", token: token) { slot in
                            fetchedTickets[i].slot = slot ?? Slot.defaultSlot()
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    if type == .past {
                        self.allPastTickets = fetchedTickets
                    } else {
                        self.allUpcomingTickets = fetchedTickets
                    }
                    completion()
                }

            } catch {
                print("❌ Ошибка парсинга билетов: \(error)")
                completion()
            }
        }.resume()
    }

    private func fetchSlot(for routeId: String, token: String, completion: @escaping (Slot?) -> Void) {
        let urlString = "\(BASE_URL)/api/routes/\(routeId)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(Slot.dateFormatter)
                let slot = try decoder.decode(Slot.self, from: data)
                completion(slot)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
