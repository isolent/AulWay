import UIKit

class PaymentProcessViewController: BaseViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expirationTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var cancelReservationButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    
    var id: String = ""
    var passengerCount: Int = 1
    var tickets: [Ticket] = []
    var paymentId: String = "pm_card_visa"

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        cancelReservationButton.addTarget(self, action: #selector(cancelReservation), for: .touchUpInside)
    }
    
    @objc private func payButtonTapped() {
        guard validateFields() else { return }
        buyTicket(routeId: id, passengerCount: passengerCount)
    }
    
    @objc private func cancelReservation() {
        dismiss(animated: true, completion: nil)
    }
    
    private func validateFields() -> Bool {
        let fields = [phoneNumberTextField, emailTextField, nameTextField, cardNumberTextField, expirationTextField, cvcTextField]
        if fields.contains(where: { $0?.text?.isEmpty ?? true }) {
            showAlert(title: "Ошибка", message: "Пожалуйста, заполните все поля.")
            return false
        }
        return true
    }
   
    private func buyTicket(routeId: String, passengerCount: Int) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            showAlert(title: "Ошибка", message: "Email пользователя не найден в UserDefaults")
            return
        }

        let paymentId = "pm_card_visa"

        guard let url = URL(string: "\(BASE_URL)/api/tickets/\(routeId)?payment_id=\(paymentId)") else {
            showAlert(title: "Ошибка", message: "Неверный URL")
            return
        }

        guard let authToken = UserDefaults.standard.string(forKey: "access_token") else {
            showAlert(title: "Ошибка", message: "Отсутствует токен авторизации")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "quantity": passengerCount,
            "user_email": email
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        print("📤 Отправляем данные: \(requestBody)")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    self.showAlert(title: "Ошибка", message: "Ошибка сети: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(title: "Ошибка", message: "Некорректный ответ сервера.")
                    return
                }

                print("📡 Статус код сервера: \(httpResponse.statusCode)")

                guard (200...299).contains(httpResponse.statusCode) else {
                    self.navigateToPaymentFailed()
                    return
                }

                guard let data = data else {
                    self.showAlert(title: "Ошибка", message: "Пустой ответ сервера")
                    return
                }

                do {
                    let decodedTickets = try JSONDecoder().decode([Ticket].self, from: data)
                    self.tickets = decodedTickets

                    if self.tickets.isEmpty {
                        self.showAlert(title: "Ошибка", message: "Билеты не найдены.")
                        return
                    }

                    self.saveTicketsToUserDefaults()
                    self.navigateToPaymentConfirmation()
                } catch {
                    self.navigateToPaymentFailed()
                }
            }
        }
        task.resume()
    }

        private func saveTicketsToUserDefaults() {
            do {
                
                let encodedData = try JSONEncoder().encode(tickets)
                UserDefaults.standard.set(encodedData, forKey: "savedTickets")

            } catch {
                print("❌ Ошибка сохранения билетов: \(error.localizedDescription)")
            }
        }
        
        private func navigateToPaymentConfirmation() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let confirmationVC = storyboard.instantiateViewController(withIdentifier: "PaymentConfirmationViewController") as? PaymentConfirmationViewController {
                confirmationVC.tickets = self.tickets
//                confirmationVC.route_id = self.id
                self.present(confirmationVC, animated: true, completion: nil)
            }
        }
        private func navigateToPaymentFailed() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let failedVC = storyboard.instantiateViewController(withIdentifier: "PaymentFailedViewController") as? PaymentFailedViewController {
                self.present(failedVC, animated: true, completion: nil)
                failedVC.passengerCount=passengerCount
                failedVC.id = id
            }
        }
    
        
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}
