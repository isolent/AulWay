//
//  ProfileViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 26.02.2025.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var editProfileButton: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable interaction and add tap gesture for the edit profile button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editProfileTapped))
        editProfileButton.isUserInteractionEnabled = true
        editProfileButton.addGestureRecognizer(tapGesture)
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
