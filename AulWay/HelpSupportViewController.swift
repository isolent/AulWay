//
//  HelpSupportViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 24.02.2025.
//

import UIKit

class HelpSupportViewController: UIViewController {

    @IBOutlet weak var infoText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchHelpSupportContent()
    }

    private func setupUI() {
        infoText.layer.cornerRadius = 20
        infoText.clipsToBounds = true
        infoText.isEditable = false
        infoText.text = "Загрузка..."
    }

    private func fetchHelpSupportContent() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("❌ Access token not found")
            return
        }

        let urlString = "\(BASE_URL)/api/pages/help_support"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let page = try JSONDecoder().decode(Page.self, from: data)
                DispatchQueue.main.async {
                    self.infoText.text = page.content
                }
            } catch {
                print("❌ Decoding failed: \(error)")
                if let json = String(data: data, encoding: .utf8) {
                    print("📩 Raw JSON response: \(json)")
                }
            }
        }.resume()
    }
}
