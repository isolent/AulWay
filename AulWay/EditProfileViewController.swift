import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    var onProfileUpdated: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
        fetchUserProfile()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        updateUserProfile()
    }

    private func fetchUserProfile() {
        guard let userId = UserDefaults.standard.string(forKey: "id"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("⚠️ No user data found, skipping fetch.")
            return
        }

        let urlString = "http://localhost:8080/api/users/\(userId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Error", message: "Fetch error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 else {
                    self.showAlert(title: "Error", message: "Failed to fetch profile. Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let firstName = json["first_name"] as? String ?? ""
                        let lastName = json["last_name"] as? String ?? ""
                        let email = json["email"] as? String ?? ""
                        let phone = json["phone"] as? String ?? ""

                        self.firstNameTextField.text = firstName
                        self.lastNameTextField.text = lastName
                        self.emailTextField.text = email
                        self.phoneNumberTextField.text = phone
                    }
                } catch {
                    self.showAlert(title: "Error", message: "Failed to parse profile data: \(error)")
                }
            }
        }
        task.resume()
    }

    private func updateUserProfile() {
        guard let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !firstName.isEmpty,
              let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !lastName.isEmpty,
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneNumber.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        guard let userId = UserDefaults.standard.string(forKey: "id"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            showAlert(title: "Error", message: "User session expired. Please log in again.")
            return
        }

        let urlString = "http://localhost:8080/api/users/\(userId)"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL.")
            return
        }

        let parameters: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone": phoneNumber
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            showAlert(title: "Error", message: "Failed to encode data.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    self.showAlert(title: "Error", message: "No response from server.")
                    return
                }

                switch httpResponse.statusCode {
                case 200...299:
                    self.handleSuccessfulUpdate(with: data)
                case 401:
                    self.showAlert(title: "Error", message: "Session expired. Please log in again.")
                default:
                    self.showAlert(title: "Error", message: "Server error. Status code: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
    }

    private func handleSuccessfulUpdate(with data: Data) {
        do {
            if let updatedUser = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                firstNameTextField.text = updatedUser["first_name"] as? String ?? ""
                lastNameTextField.text = updatedUser["last_name"] as? String ?? ""
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
            showAlert(title: "Error", message: "Failed to parse updated user data.")
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

        // Check for new user flag, if it exists, clear defaults and return
        if defaults.bool(forKey: "isNewUser") {
            clearUserDefaultsForProfile()
            defaults.set(false, forKey: "isNewUser") // Reset the flag
            defaults.synchronize()
            return
        }

        let firstName = defaults.string(forKey: "firstname") ?? ""
        let lastName = defaults.string(forKey: "lastname") ?? ""
        let email = defaults.string(forKey: "email") ?? ""
        let phone = defaults.string(forKey: "phone") ?? ""

        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        emailTextField.text = email
        phoneNumberTextField.text = phone
    }

    private func clearUserDefaultsForProfile() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "firstname")
        defaults.removeObject(forKey: "lastname")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "phone")
        defaults.synchronize()
    }
}
