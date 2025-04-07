//
//  HomeViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/26/24.
//

import UIKit

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var From: UITextField!
    @IBOutlet weak var To: UITextField!
    @IBOutlet weak var SelectedDate: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var PassengerInfo: UILabel!
    
    var passengerCount: Int = 1 {
        didSet {
            PassengerInfo.text = "\(passengerCount) пассажир"
        }
    }

    var slotCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
    
    func setupUI() {
        PassengerInfo.text = "\(passengerCount) пассажир"
        PassengerInfo.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)

        PassengerInfo.layer.cornerRadius = PassengerInfo.frame.height / 2
        PassengerInfo.layer.masksToBounds = true
        
        From.layer.cornerRadius = From.frame.height / 2
        From.layer.masksToBounds = true
        To.layer.cornerRadius = To.frame.height / 2
        To.layer.masksToBounds = true
        
        From.attributedPlaceholder = NSAttributedString(
            string: "Откуда",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        To.attributedPlaceholder = NSAttributedString(
            string: "Куда",
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
        
        fetchRoutes(departure: fromText, destination: toText, date: SelectedDate.date, passengers: passengerCount)
    }
    
    func fetchRoutes(departure: String, destination: String, date: Date, passengers: Int) {
        let baseURL = "\(BASE_URL)/api/routes"
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

        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            showAlert(message: "Вы не вошли. Пожалуйста, войдите в систему еще раз.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(message: "Нет ответа от сервера.")
                    return
                }

                if httpResponse.statusCode == 401 {
                    self.showAlert(message: "Сеанс истек. Пожалуйста, войдите в систему еще раз.")
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    self.showAlert(message: "Ошибка сервера: \(httpResponse.statusCode)")
                    return
                }

                guard let data = data else {
                    self.showAlert(message: "Данные не получены.")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let slots = try decoder.decode([Slot].self, from: data)

                    self.slotCount = slots.count
                    print("✅ Найдено маршрутов: \(self.slotCount)")

                    self.performSegue(withIdentifier: "toLoading", sender: self)
                } catch {
                    self.showAlert(message: "Ошибка при разборе JSON: \(error.localizedDescription)")
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
            if let loadingVC = segue.destination as? LoadingViewController {
                loadingVC.fromLocation = From.text ?? ""
                loadingVC.toLocation = To.text ?? ""
                loadingVC.travelDate = SelectedDate.date
                loadingVC.passengerCount = passengerCount
                loadingVC.slotList = Array(repeating: Slot(), count: slotCount)
            }
        }
    }
}
