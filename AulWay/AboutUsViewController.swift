//
//  AboutUsViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 24.02.2025.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var textLabel: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchAboutUsContent()
    }

    private func setupUI() {
        textLabel.layer.cornerRadius = 20
        textLabel.clipsToBounds = true
        textLabel.isEditable = false
        textLabel.text = "Загрузка..."
    }

    private func fetchAboutUsContent() {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("❌ Access token not found")
            return
        }

        let urlString = "http://localhost:8080/api/pages/about_us"
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
                    self.textLabel.text = page.content
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
