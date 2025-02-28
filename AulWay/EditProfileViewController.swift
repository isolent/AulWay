import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let userId = "user_id" // Replace with actual user ID logic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        updateUserProfile()
    }

    private func updateUserProfile() {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        let urlString = "http://localhost:8080/api/users/\(userId)"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL.")
            return
        }

        let parameters: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phoneNumber": phoneNumber
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UIPasteboard.general.string {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

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

                if (200...299).contains(httpResponse.statusCode) {
                    do {
                        let updatedUser = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Updated User Data: \(updatedUser)") // Prints updated data in console
                        
                        self.showAlert(title: "Success", message: "Profile updated successfully.")
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
        defaults.setValue(firstName, forKey: "firstName")
        defaults.setValue(lastName, forKey: "lastName")
        defaults.setValue(email, forKey: "email")
        defaults.setValue(phoneNumber, forKey: "phoneNumber")
    }

    private func loadUserData() {
        let defaults = UserDefaults.standard
        firstNameTextField.text = defaults.string(forKey: "firstName")
        lastNameTextField.text = defaults.string(forKey: "lastName")
        emailTextField.text = defaults.string(forKey: "email")
        phoneNumberTextField.text = defaults.string(forKey: "phoneNumber")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
