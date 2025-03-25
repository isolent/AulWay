import UIKit

class UserTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    enum TicketType {
        case past
        case upcoming
    }

    var currentTicketType: TicketType = .past
    var pastTickets: [Ticket] = []
    var upcomingTickets: [Ticket] = []

    @IBOutlet weak var tickets: UITableView!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var pastButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tickets.delegate = self
        tickets.dataSource = self
        styleButtons()
        fetchTickets()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🔄 UserTicketsViewController appeared — обновляем билеты")
        fetchTickets()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTicketType == .past ? pastTickets.count : upcomingTickets.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell

        let ticket = currentTicketType == .past ? pastTickets[indexPath.row] : upcomingTickets[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        cell.Date.text = dateFormatter.string(from: ticket.slot.start_date)

        let duration = ticket.slot.end_date.timeIntervalSince(ticket.slot.start_date) / 3600
        cell.Duration.text = String(format: "%.2f hours", duration)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        cell.Time.text = "\(timeFormatter.string(from: ticket.slot.start_date)) - \(timeFormatter.string(from: ticket.slot.end_date))"

        cell.Path.text = "\(ticket.slot.departure) - \(ticket.slot.destination)"
        cell.Status.text = ticket.paid ? "Paid" : "Unpaid"
        cell.CarNumber.text = ticket.slot.carNumber ?? "-"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tickets.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func switchTicketType(_ sender: UIButton) {
        currentTicketType = sender == upcomingButton ? .upcoming : .past
        updateButtonStyles()
        tickets.reloadData()
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

        fetchTickets(for: "past", userId: userId, token: token) { tickets in
            let newTickets = tickets.filter { newTicket in
                !self.pastTickets.contains(where: { $0.id == newTicket.id })
            }
            self.pastTickets.append(contentsOf: newTickets)
            if self.currentTicketType == .past {
                DispatchQueue.main.async {
                    self.tickets.reloadData()
                }
            }
        }

        fetchTickets(for: "upcoming", userId: userId, token: token) { tickets in
            let newTickets = tickets.filter { newTicket in
                !self.upcomingTickets.contains(where: { $0.id == newTicket.id })
            }
            self.upcomingTickets.append(contentsOf: newTickets)
            if self.currentTicketType == .upcoming {
                DispatchQueue.main.async {
                    self.tickets.reloadData()
                }
            }
        }
    }

    private func fetchTickets(for type: String, userId: String, token: String, completion: @escaping ([Ticket]) -> Void) {
        let urlString = "http://localhost:8080/api/tickets/users/\(userId)?type=\(type)"
        guard let url = URL(string: urlString) else {
            print("❌ Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка загрузки \(type) билетов: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                print("❌ Пустой ответ при получении \(type) билетов")
                completion([])
                return
            }

            do {
                var tickets = try JSONDecoder().decode([Ticket].self, from: data)
                let group = DispatchGroup()

                for i in 0..<tickets.count {
                    if tickets[i].slot.departure == "Unknown" {
                        group.enter()
                        self.fetchSlot(for: tickets[i].route_id ?? "", token: token) { slot in
                            tickets[i].slot = slot ?? Slot.defaultSlot()
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    print("✅ \(type.capitalized) билеты успешно загружены: \(tickets.count)")
                    completion(tickets)
                }
            } catch {
                print("❌ Ошибка парсинга \(type) билетов: \(error)")
                completion([])
            }
        }.resume()
    }

    private func fetchSlot(for routeId: String, token: String, completion: @escaping (Slot?) -> Void) {
        let urlString = "http://localhost:8080/api/routes/\(routeId)"
        guard let url = URL(string: urlString) else {
            print("❌ Неверный URL слота")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("❌ Нет данных от API слота")
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(Slot.dateFormatter)
                let slot = try decoder.decode(Slot.self, from: data)
                print("📩 Slot для routeId \(routeId): \(slot.departure) - \(slot.destination)")
                completion(slot)
            } catch {
                print("❌ Ошибка декодирования слота: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
