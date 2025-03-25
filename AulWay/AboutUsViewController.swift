//
//  AboutUsViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 24.02.2025.
//

import UIKit
class AboutUsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.layer.cornerRadius = 20
        textLabel.clipsToBounds = true
    }
    
    @IBOutlet weak var textLabel: UITextView!
}
//
//class AboutUsViewController: UIViewController {
//
//    @IBOutlet weak var textLabel: UITextView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        textLabel.layer.cornerRadius = 20
//        textLabel.clipsToBounds = true
//        fetchPageContent(title: "about_us")
//    }
//
//    private func fetchPageContent(title: String) {
//        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
//            print("❌ No access token found")
//            textLabel.text = "Ошибка: отсутствует токен"
//            return
//        }
//
//        guard let url = URL(string: "http://localhost:8080/api/pages/\(title)") else {
//            print("❌ Invalid URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("❌ Network error: \(error.localizedDescription)")
//                    self.textLabel.text = "Ошибка подключения"
//                    return
//                }
//
//                guard let data = data else {
//                    print("❌ No data received")
//                    self.textLabel.text = "Нет данных от сервера"
//                    return
//                }
//
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let content = json["Content"] as? String {
//                        self.textLabel.text = content
//                    } else {
//                        print("⚠️ Unexpected response format")
//                        print("📦 Response:", String(data: data, encoding: .utf8) ?? "n/a")
//                        self.textLabel.text = "Ошибка при получении текста"
//                    }
//                } catch {
//                    print("❌ JSON parsing error: \(error.localizedDescription)")
//                    self.textLabel.text = "Ошибка при обработке данных"
//                }
//            }
//        }.resume()
//    }
//}
