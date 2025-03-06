import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var editProfileButton: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var phoneContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchUserData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editProfileTapped))
        editProfileButton.isUserInteractionEnabled = true
        editProfileButton.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData()
    }
    
    private func setupUI() {
        let containers = [nameContainer, emailContainer, phoneContainer]
        
        for container in containers {
            container?.translatesAutoresizingMaskIntoConstraints = false
            container?.layer.cornerRadius = 25
            container?.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
            container?.clipsToBounds = true
            
            if let container = container {
                NSLayoutConstraint.activate([
                    container.widthAnchor.constraint(equalToConstant: 300),
                    container.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
        }
    }
    
    private func fetchUserData() {
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"),
              let userId = UserDefaults.standard.string(forKey: "user_id") else {
            print("⚠️ No user session found")
            return
        }

        let url = URL(string: "http://localhost:8080/api/users/\(userId)")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Выводим JSON-ответ сервера в консоль
            print("📩 Server Response:", String(data: data, encoding: .utf8) ?? "Invalid data")

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        let firstName = jsonResponse["first_name"] as? String ?? "N/A"
                        let lastName = jsonResponse["last_name"] as? String ?? "N/A"
                        self.nameLabel.text = "\(firstName) \(lastName)"
                        self.emailLabel.text = jsonResponse["email"] as? String ?? "N/A"
                        self.phoneLabel.text = jsonResponse["phone"] as? String ?? "N/A"
                    }
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.logoutUser()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func logoutUser() {
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token") else {
            print("⚠️ No access token found, logging out locally")
            completeLogout()
            return
        }

        let url = URL(string: "http://localhost:8080/auth/logout")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ Successfully logged out from server")
                } else {
                    print("⚠️ Server responded with status code: \(httpResponse.statusCode)")
                }
            }
            
            DispatchQueue.main.async {
                self.completeLogout()
            }
        }
        task.resume()
    }


    private func completeLogout() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "user_id")
        
        if let welcomeVC = storyboard?.instantiateViewController(withIdentifier: "wellcome") {
            welcomeVC.modalPresentationStyle = .fullScreen
            present(welcomeVC, animated: true, completion: nil)
        }
    }

    
    @objc func editProfileTapped() {
        guard let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else {
            print("❌ Error: Edit Profile screen not found")
            return
        }
        editProfileVC.onProfileUpdated = { [weak self] in
            self?.fetchUserData()
        }
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
}
