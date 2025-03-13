import UIKit

class PaymentProcessViewController: UIViewController {
    
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
    var qrCodeBase64: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        cancelReservationButton.addTarget(self, action: #selector(cancelReservation), for: .touchUpInside)
    }
    
    @objc func payButtonTapped() {
        guard let phone = phoneNumberTextField.text, !phone.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty,
              let expiration = expirationTextField.text, !expiration.isEmpty,
              let cvc = cvcTextField.text, !cvc.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        createTicket(id: id, passengerCount: passengerCount)
    }
    
    @objc func cancelReservation() {
        dismiss(animated: true, completion: nil)
    }
    
    func createTicket(id: String, passengerCount: Int) {
        let urlString = "http://localhost:8080/api/tickets/\(id)"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            showAlert(title: "Error", message: "Authorization token is missing")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "phone_number": phoneNumberTextField.text ?? "",
            "email": emailTextField.text ?? "",
            "name": nameTextField.text ?? "",
            "card_number": cardNumberTextField.text ?? "",
            "expiration": expirationTextField.text ?? "",
            "cvc": cvcTextField.text ?? "",
            "quantity": passengerCount
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self.showAlert(title: "Error", message: "No response from server.")
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                       let firstTicket = jsonResponse.first {
                        
                        print("Server response:", firstTicket)
                        
                        if let status = firstTicket["payment_status"] as? String, status == "pending",
                           let qrCodeBase64 = firstTicket["qr_code"] as? String {
                            
                            self.qrCodeBase64 = qrCodeBase64
                            
                            DispatchQueue.main.async {
                                self.navigateToPaymentConfirmation()
                            }
                        } else {
                            self.showAlert(title: "Error", message: "Payment failed. Please try again.")
                        }
                    } else {
                        self.showAlert(title: "Error", message: "Unexpected response format.")
                    }
                } catch {
                    self.showAlert(title: "Error", message: "Failed to process server response.")
                }
            }
        }
        task.resume()
    }

    func navigateToPaymentConfirmation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let confirmationVC = storyboard.instantiateViewController(withIdentifier: "PaymentConfirmationViewController") as? PaymentConfirmationViewController {
            confirmationVC.id = self.id
            confirmationVC.qrCodeBase64 = self.qrCodeBase64
            self.navigationController?.pushViewController(confirmationVC, animated: true)
        }
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
