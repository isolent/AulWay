//
//  HomeViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/26/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var From: UITextField!
    @IBOutlet weak var To: UITextField!
    @IBOutlet weak var SelectedDate: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var PassengerInfo: UILabel!
    
    var passengerCount: Int = 1 {
        didSet {
            PassengerInfo.text = "\(passengerCount) passenger"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        PassengerInfo.text = "\(passengerCount) passenger"
        PassengerInfo.backgroundColor = UIColor.lightGray
        PassengerInfo.layer.cornerRadius = PassengerInfo.frame.height / 2
        PassengerInfo.layer.masksToBounds = true
        
        From.layer.cornerRadius = From.frame.height / 2
        From.layer.masksToBounds = true
        To.layer.cornerRadius = To.frame.height / 2
        To.layer.masksToBounds = true
        
        From.attributedPlaceholder = NSAttributedString(
            string: "From",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        To.attributedPlaceholder = NSAttributedString(
            string: "To",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        SelectedDate.minimumDate = Date()
        searchButton.layer.cornerRadius = 10
        searchButton.clipsToBounds = true
    }
    
    @IBAction func increasePassengerCount(_ sender: UIButton) {
        passengerCount += 1
    }
    
    @IBAction func decreasePassengerCount(_ sender: UIButton) {
        if passengerCount > 1 {
            passengerCount -= 1
        }
    }
    
    @IBAction func searchForTickets(_ sender: UIButton) {
        guard let fromText = From.text, !fromText.isEmpty else {
            showAlert(message: "Please enter the 'From' location.")
            return
        }
        
        guard let toText = To.text, !toText.isEmpty else {
            showAlert(message: "Please enter the 'To' location.")
            return
        }
        
        fetchTickets(departure: fromText, destination: toText, date: SelectedDate.date, passengers: passengerCount)
    }
    
    func fetchTickets(departure: String, destination: String, date: Date, passengers: Int) {
        let baseURL = "http://localhost:8080/api/routes"
        var components = URLComponents(string: baseURL)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        components?.queryItems = [
            URLQueryItem(name: "departure", value: departure),
            URLQueryItem(name: "destination", value: destination),
            URLQueryItem(name: "date", value: dateFormatter.string(from: date)),
            URLQueryItem(name: "passengers", value: "\(passengers)"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "pageSize", value: "10")
        ]

        guard let url = components?.url else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // ✅ Fetching authentication token properly
        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ No authentication token found.")
            showAlert(message: "You are not authenticated. Please log in again.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(message: "Error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(message: "No response from server.")
                    return
                }

                // ✅ Debugging Unauthorized Access
                if httpResponse.statusCode == 401 {
                    print("❌ Unauthorized: Invalid token or session expired.")
                    self.showAlert(message: "Session expired. Please log in again.")
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    self.showAlert(message: "Server error: \(httpResponse.statusCode)")
                    return
                }

                guard let data = data else {
                    self.showAlert(message: "No data received.")
                    return
                }

                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✅ Response:", jsonResponse)
                    self.performSegue(withIdentifier: "toLoading", sender: self)
                } catch {
                    self.showAlert(message: "JSON Parsing Error: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }

    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLoading" {
            if let ticketListVC = segue.destination as? LoadingViewController {
                ticketListVC.fromLocation = From.text ?? ""
                ticketListVC.toLocation = To.text ?? ""
                ticketListVC.travelDate = SelectedDate.date
                ticketListVC.passengerCount = passengerCount
            }
        }
    }
}
