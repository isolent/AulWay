import UIKit

class EditProfileViewController: BaseViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    var onProfileUpdated: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
        configureTextField(firstNameTextField)
        configureTextField(lastNameTextField)
        configureTextField(emailTextField)
        configureTextField(phoneNumberTextField)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        updateUserProfile()
    }

    private func updateUserProfile() {
        guard let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !firstName.isEmpty,
              let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !lastName.isEmpty,
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneNumber.isEmpty else {
            showAlert(title: "Ошибка", message: "Пожалуйста, заполните все поля.")
            return
        }

        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            print("⚠️ No user ID found")
            showAlert(title: "Ошибка", message: "Пользователь не найден. Пожалуйста, зарегистрируйтесь заново.")
            return
        }

        let urlString = "\(BASE_URL)/api/users/\(userId)"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Ошибка", message: "Неверный URL-адрес.")
            return
        }

        guard let authToken = UserDefaults.standard.string(forKey: "access_token") else {
            showAlert(title: "Ошибка", message: "Отсутствует токен авторизации")
            return
        }
        
        let parameters: [String: Any] = [
            "firstname": firstName,
            "lastname": lastName,
            "email": email,
            "phone": phoneNumber
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            if let jsonString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("\n📤 PUT Body JSON:\n\(jsonString)\n")
            }
        } catch {
            showAlert(title: "Ошибка", message: "Не удалось закодировать данные.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Ошибка", message: "Запрос не выполнен: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    self.showAlert(title: "Ошибка", message: "Нет ответа от сервера.")
                    return
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    print("\n📥 Server Response (\(httpResponse.statusCode)):\n\(responseString)\n")
                }

                switch httpResponse.statusCode {
                case 200...299:
                    self.handleSuccessfulUpdate(with: data)
                default:
                    var message = "Ошибка сервера. Код состояния: \(httpResponse.statusCode)"
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let serverMessage = json["errDesc"] as? String {
                        if serverMessage.contains("duplicate key value") {
                            message = "Этот email уже используется. Попробуйте другой."
                        } else {
                            message = serverMessage
                        }
                    }
                    self.showAlert(title: "Ошибка", message: message)
                }
            }
        }
        task.resume()
    }

    private func handleSuccessfulUpdate(with data: Data) {
        do {
            if let updatedUser = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                firstNameTextField.text = updatedUser["firstname"] as? String ?? ""
                lastNameTextField.text = updatedUser["lastname"] as? String ?? ""
                emailTextField.text = updatedUser["email"] as? String ?? ""
                phoneNumberTextField.text = updatedUser["phone"] as? String ?? ""

                onProfileUpdated?()
                showAlert(title: "Success", message: "Profile updated successfully.") { _ in
                    if let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "Tickets") {
                        searchVC.modalPresentationStyle = .fullScreen
                        self.present(searchVC, animated: true, completion: nil)
                    }
                }
            }
        } catch {
            showAlert(title: "Ошибка", message: "Failed to parse updated user data.")
        }
    }

    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }

    private func saveUserData(firstName: String, lastName: String, email: String, phoneNumber: String) {
        print("📌 Saving to UserDefaults:", firstName, lastName, email, phoneNumber)
        let defaults = UserDefaults.standard
        defaults.setValue(firstName, forKey: "firstname")
        defaults.setValue(lastName, forKey: "lastname")
        defaults.setValue(email, forKey: "email")
        defaults.setValue(phoneNumber, forKey: "phone")
        defaults.synchronize()
    }

    private func loadUserData() {
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: "isNewUser") {
            clearUserDefaultsForProfile()
            defaults.set(false, forKey: "isNewUser")
            defaults.synchronize()
            return
        }

        let firstName = defaults.string(forKey: "firstname")
        let lastName = defaults.string(forKey: "lastname")
        let email = defaults.string(forKey: "email")
        let phone = defaults.string(forKey: "phone")

        if let firstName = firstName, !firstName.isEmpty {
            firstNameTextField.text = firstName
        }

        if let lastName = lastName, !lastName.isEmpty {
            lastNameTextField.text = lastName
        }

        if let email = email, !email.isEmpty {
            emailTextField.text = email
        }

        if let phone = phone, !phone.isEmpty {
            phoneNumberTextField.text = phone
        }
    }


    private func clearUserDefaultsForProfile() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "firstname")
        defaults.removeObject(forKey: "lastname")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "phone")
        defaults.synchronize()
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.clipsToBounds = true
    }
}
