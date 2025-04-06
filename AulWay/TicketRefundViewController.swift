//
//  TicketRefundViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 04.04.2025.
//

import UIKit

class TicketRefundViewController: BaseViewController {

    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var refundAmountLabel: UILabel!
    @IBOutlet weak var agreeCheckbox: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var refundRules: UILabel!
    
    var ticket: Ticket?
    var userId: String = ""

    private var agreedToRules = false {
        didSet {
            updateContinueButtonState()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissSelf))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(refundRulesTapped))
        refundRules.isUserInteractionEnabled = true
        refundRules.addGestureRecognizer(tapGesture)
    }

    private func setupUI() {
        guard let ticket = ticket else {
            print("⚠️ No ticket passed to refund screen")
            return
        }


        routeLabel.text = "\(ticket.slot.departure) - \(ticket.slot.destination)"

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        dateLabel.text = formatter.string(from: ticket.slot.start_date)

        busNumberLabel.text = ticket.slot.carNumber ?? "–"
        statusLabel.text = ticket.payment_status.capitalized
        departureTimeLabel.text = formattedTime(ticket.slot.start_date)
        arrivalTimeLabel.text = formattedTime(ticket.slot.end_date)
        priceLabel.text = "\(ticket.price) ₸"
        refundAmountLabel.text = "\(ticket.price) ₸"
        orderNumberLabel.text = ticket.order_number

        agreeCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func updateContinueButtonState() {
        continueButton.isEnabled = agreedToRules
        continueButton.alpha = agreedToRules ? 1.0 : 0.5

        let imageName = agreedToRules ? "checkmark.square.fill" : "square"
        agreeCheckbox.setImage(UIImage(systemName: imageName), for: .normal)

    }

    @IBAction func agreeCheckboxTapped(_ sender: UIButton) {
        agreedToRules.toggle()
        if agreedToRules {
            refundRulesTapped()
        }
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard agreedToRules else {
            print("❌ User did not agree to refund rules")
            return
        }
        guard let ticket = ticket else {
            print("❌ No ticket data found")
            return
        }
        performTicketRefund(ticketId: ticket.id)
    }

    private func performTicketRefund(ticketId: String) {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("❌ No auth token found in UserDefaults")
            showAlert(title: "Ошибка", message: "Токен не найден.")
            return
        }
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            print("❌ No email found in UserDefaults")
            showAlert(title: "Ошибка", message: "Email не найден.")
            return
        }

        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(BASE_URL)/api/tickets/users/\(userId)/\(ticketId)/cancel?email=\(encodedEmail)") else {
            print("❌ Failed to build refund URL")
            showAlert(title: "Ошибка", message: "Неверный URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Refund request failed: \(error.localizedDescription)")
                    self.showAlert(title: "Ошибка", message: error.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ No HTTP response")
                    self.showAlert(title: "Ошибка", message: "Некорректный ответ сервера.")
                    return
                }

                print("📡 Refund response status: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    print("✅ Ticket successfully cancelled")
                    self.showAlert(title: "Успешно", message: "Билет отменён.") {
                        NotificationCenter.default.post(name: NSNotification.Name("TicketCancelled"), object: nil)
                        self.navigateToUserTickets()
                    }
                } else {
                    print("❌ Ticket cancellation failed with status code: \(httpResponse.statusCode)")
                    self.showAlert(title: "Ошибка", message: "Не удалось отменить билет.")
                }
            }
        }.resume()
    }


    private func navigateToUserTickets() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "Tickets") as? UITabBarController else {
            print("❌ Could not instantiate MainTabBarController from storyboard")
            return
        }

        tabBarController.selectedIndex = 1

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            print("✅ Replaced root with MainTabBarController, switched to index 1")
        } else {
            print("❌ Failed to access app window")
        }
    }



    private func showAlert(title: String, message: String, onClose: (() -> Void)? = nil) {
        print("📣 Alert: \(title) — \(message)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ОК", style: .default) { _ in onClose?() }
        alert.addAction(ok)
        self.present(alert, animated: true)
    }

    @objc private func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getTabBarController() -> UITabBarController? {
        var parent = self.presentingViewController
        while parent != nil {
            if let tab = parent as? UITabBarController {
                return tab
            }
            parent = parent?.presentingViewController
        }

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let tab = window.rootViewController as? UITabBarController {
            return tab
        }

        return nil
    }
    
    @objc private func refundRulesTapped() {
        let message = """
        Возврат возможен только за 24 часов до отправления автобуса.
        После отправления билета возврат невозможен.
        При отмене билета средства возвращаются на ту же карту, с которой была произведена оплата.
        Возврат осуществляется в течение 5–10 рабочих дней в зависимости от банка.
        Частичный возврат возможен, если в заказе было приобретено несколько билетов.
        """
        
        let alert = UIAlertController(title: "Правила возврата", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
