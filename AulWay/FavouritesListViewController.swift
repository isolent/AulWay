//
//  FavouritesListViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 30.03.2025.
//

import UIKit

class FavouritesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var allFavouriteSlots: [Slot] = []
    private var currentPageSlots: [Slot] = []
    private var currentPage = 1
    private let pageSize = 10
    private var isLoading = false

    private let prevPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("←", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .regular)
        button.isEnabled = false
        return button
    }()

    private let nextPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("→", for: .normal)
        button.setTitleColor(.white, for: .normal)
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
        tableView.dataSource = self
        tableView.delegate = self

        setupPaginationUI()
        fetchFavourites()
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
        updateCurrentPage()
    }

    @objc private func nextPageTapped() {
        let totalPages = Int(ceil(Double(allFavouriteSlots.count) / Double(pageSize)))
        guard currentPage < totalPages else { return }
        currentPage += 1
        updateCurrentPage()
    }

    private func updateCurrentPage() {
        let startIndex = (currentPage - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allFavouriteSlots.count)
        currentPageSlots = Array(allFavouriteSlots[startIndex..<endIndex])
        tableView.reloadData()
        updatePaginationUI()
    }

    private func updatePaginationUI() {
        pageLabel.text = "Page \(currentPage)"
        let totalPages = Int(ceil(Double(allFavouriteSlots.count) / Double(pageSize)))

        prevPageButton.isEnabled = currentPage > 1
        nextPageButton.isEnabled = currentPage < totalPages

        prevPageButton.titleLabel?.font = .systemFont(ofSize: 24, weight: prevPageButton.isEnabled ? .bold : .regular)
        nextPageButton.titleLabel?.font = .systemFont(ofSize: 24, weight: nextPageButton.isEnabled ? .bold : .regular)
    }

    private func fetchFavourites() {
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ Missing user_id or token")
            return
        }

        let urlString = "\(BASE_URL)/api/users/\(userId)/favorites"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }

            if let error = error {
                print("❌ Error loading favorites: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let slots = try decoder.decode([Slot].self, from: data)

                DispatchQueue.main.async {
                    self.allFavouriteSlots = slots
                    self.currentPage = 1
                    self.updateCurrentPage()
                }

            } catch {
                print("❌ Decoding error: \(error)")
            }
        }.resume()
    }

    // MARK: UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPageSlots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let slot = currentPageSlots[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketListTableViewCell", for: indexPath) as! TicketListTableViewCell

        cell.configure(with: slot)
        cell.onFavouriteTapped = {
            print("Tapped heart for: \(slot.id ?? "")")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedSlot = currentPageSlots[indexPath.row]

        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "RouteDetailsViewController") as? RouteDetailsViewController {
            detailsVC.selectedSlot = selectedSlot
            detailsVC.fromLocation = selectedSlot.departure
            detailsVC.toLocation = selectedSlot.destination
            detailsVC.travelDate = selectedSlot.start_date
            detailsVC.passengerCount = 1
            present(detailsVC, animated: true)
        }
    }
}
