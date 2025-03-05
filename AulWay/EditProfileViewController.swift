import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        updateUserProfile()
    }

    private func updateUserProfile() {
        // Get values from text fields
        guard let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !firstName.isEmpty,
              let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !lastName.isEmpty,
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneNumber.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        // Get user ID from storage
        guard let userId = UserDefaults.standard.string(forKey: "id"), !userId.isEmpty else {
            showAlert(title: "Error", message: "User ID not found. Please log in again.")
            return
        }

        // Get token from storage
        guard let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty else {
            showAlert(title: "Error", message: "Authentication required. Please log in again.")
            return
        }

        let urlString = "http://localhost:8080/api/users/\(userId)"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL.")
            return
        }

        let parameters: [String: Any] = [
            "firstname": firstName,
            "lastname": lastName,
            "email": email,
            "phone": phoneNumber
        ]

        print("🔑 Auth Token: \(token)")
        print("🌍 API URL: \(urlString)")
        print("📩 Request Parameters: \(parameters)")

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

                print("📡 Response Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 401 {
                    self.showAlert(title: "Error", message: "Session expired. Please log in again.")
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    do {
                        if let updatedUser = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("✅ Updated User Data: \(updatedUser)")
                            
                            let updatedFirstName = updatedUser["firstname"] as? String ?? firstName
                            let updatedLastName = updatedUser["lastname"] as? String ?? lastName
                            let updatedEmail = updatedUser["email"] as? String ?? email
                            let updatedPhone = updatedUser["phone"] as? String ?? phoneNumber

                            self.saveUserData(firstName: updatedFirstName, lastName: updatedLastName, email: updatedEmail, phoneNumber: updatedPhone)

                            self.loadUserData()
                            
                        
                            self.showAlert(title: "Success", message: "Profile updated successfully.") { _ in
                                if let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "Tickets") {
                                    searchVC.modalPresentationStyle = .fullScreen
                                    self.present(searchVC, animated: true, completion: nil)
                                }
                            }
                        }
                    } catch {
                        self.showAlert(title: "Error", message: "Failed to parse updated user data.")
                    }
                } else {
                    self.showAlert(title: "Error", message: "Server error. Status code: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
    }

    private func saveUserData(firstName: String, lastName: String, email: String, phoneNumber: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(firstName, forKey: "firstname")
        defaults.setValue(lastName, forKey: "lastname")
        defaults.setValue(email, forKey: "email")
        defaults.setValue(phoneNumber, forKey: "phone")
        defaults.synchronize()
    }

    private func loadUserData() {
        let defaults = UserDefaults.standard
        firstNameTextField.text = defaults.string(forKey: "firstname") ?? ""
        lastNameTextField.text = defaults.string(forKey: "lastname") ?? ""
        emailTextField.text = defaults.string(forKey: "email") ?? ""
        phoneNumberTextField.text = defaults.string(forKey: "phone") ?? ""
    }

    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }
}
