//
//  RefundedTicketsViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 05.04.2025.
//

import UIKit

class RefundedTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var allCancelledTickets: [Ticket] = []
    var currentPageTickets: [Ticket] = []
    var currentPage = 1
    let pageSize = 10

    private var slotCache: [String: Slot] = [:]

    private let pageLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    private let noTicketsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "У вас нет отменённых билетов"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(name: "Avenir Next", size: 24)
        label.textColor = .white
        return label
    }()

    private let findTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Найти билет", for: .normal)
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.85)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 20
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupPaginationUI()
        setupEmptyStateUI()
        fetchCancelledTickets()
    }

    private func fetchCancelledTickets() {
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
              let token = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "\(BASE_URL)/api/tickets/users/\(userId)/cancelled")
        else {
            print("❌ Missing userId, token or invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error:", error.localizedDescription)
                    return
                }

                guard let data = data else { return }

                do {
                    let tickets = try JSONDecoder().decode([Ticket].self, from: data)
                    self.allCancelledTickets = tickets.filter { $0.status.lowercased() == "cancelled" }

                    if self.allCancelledTickets.isEmpty {
                        self.tableView.isHidden = true
                        self.noTicketsLabel.isHidden = false
                        self.findTicketButton.isHidden = false
                    } else {
                        self.tableView.isHidden = false
                        self.noTicketsLabel.isHidden = true
                        self.findTicketButton.isHidden = true
                        self.updateCurrentPage()
                    }
                } catch {
                    print("❌ Decode error:", error)
                }
            }
        }.resume()
    }

    private func fetchSlot(for routeId: String, completion: @escaping (Slot?) -> Void) {
        if let cached = slotCache[routeId] {
            completion(cached)
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "\(BASE_URL)/api/routes/\(routeId)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let slot = try JSONDecoder().decode(Slot.self, from: data)
                    self.slotCache[routeId] = slot
                    completion(slot)
                } catch {
                    print("❌ Failed to decode slot:", error)
                    completion(nil)
                }
            } else {
                print("❌ Failed to fetch slot:", error?.localizedDescription ?? "")
                completion(nil)
            }
        }.resume()
    }

    private func setupPaginationUI() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        pageLabel.text = "Page 1"
        pageLabel.textColor = .white

        prevButton.setTitle("←", for: .normal)
        nextButton.setTitle("→", for: .normal)
        prevButton.tintColor = .white
        nextButton.tintColor = .white

        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        stack.addArrangedSubview(prevButton)
        stack.addArrangedSubview(pageLabel)
        stack.addArrangedSubview(nextButton)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
        noTicketsLabel.isHidden = true
        findTicketButton.isHidden = true
    }

    @objc private func findTicketTapped() {
        tabBarController?.selectedIndex = 0
    }

    @objc private func prevTapped() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        updateCurrentPage()
    }

    @objc private func nextTapped() {
        let totalPages = Int(ceil(Double(allCancelledTickets.count) / Double(pageSize)))
        guard currentPage < totalPages else { return }
        currentPage += 1
        updateCurrentPage()
    }

    private func updateCurrentPage() {
        let start = (currentPage - 1) * pageSize
        let end = min(start + pageSize, allCancelledTickets.count)
        currentPageTickets = Array(allCancelledTickets[start..<end])
        pageLabel.text = "Page \(currentPage)"
        tableView.reloadData()
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPageTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ticket = currentPageTickets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketListTableViewCell", for: indexPath) as! TicketListTableViewCell
        cell.orderNumber.text = ticket.order_number

        if let slot = slotCache[ticket.route_id!] {
            cell.configure(with: slot)
        } else {
            fetchSlot(for: ticket.route_id!) { slot in
                DispatchQueue.main.async {
                    if let slot = slot {
                        self.slotCache[ticket.route_id!] = slot
                        if let updatedCell = tableView.cellForRow(at: indexPath) as? TicketListTableViewCell {
                            updatedCell.configure(with: slot)
                        }
                    }
                }
            }
        }

        return cell
    }
}
