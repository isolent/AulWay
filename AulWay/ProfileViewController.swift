import UIKit
import FirebaseAuth

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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editProfileTapped))
        editProfileButton.isUserInteractionEnabled = true
        editProfileButton.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        let containers = [nameContainer, emailContainer, phoneContainer]
        
        for container in containers {
            container?.translatesAutoresizingMaskIntoConstraints = false
            container?.layer.cornerRadius = 25
            container?.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
            container?.clipsToBounds = true
            
            // Set fixed width and height
            if let container = container {
                NSLayoutConstraint.activate([
                    container.widthAnchor.constraint(equalToConstant: 300),
                    container.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
        }
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out",
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.logoutUser()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            print("✅ Successfully logged out")
            
            // Navigate to the Welcome/Login page
            if let welcomeVC = storyboard?.instantiateViewController(withIdentifier: "wellcome") {
                welcomeVC.modalPresentationStyle = .fullScreen
                present(welcomeVC, animated: true, completion: nil)
            }
        } catch let error {
            print("❌ Error logging out: \(error.localizedDescription)")
        }
    }
    
    @objc func editProfileTapped() {
        guard let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") else {
            print("❌ Error: Edit Profile screen not found")
            return
        }
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
}
