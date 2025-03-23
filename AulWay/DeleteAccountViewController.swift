//
//  DeleteAccountViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 24.02.2025.
//

import UIKit

class DeleteAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let confirmAlert = UIAlertController(
            title: "Удалить аккаунт",
            message: "Вы уверены, что хотите безвозвратно удалить аккаунт?",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        confirmAlert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
            self.performDeleteRequest()
        }))

        present(confirmAlert, animated: true)
    }

    private func performDeleteRequest() {
        guard let userId = UserDefaults.standard.string(forKey: "user_id"),
              let token = UserDefaults.standard.string(forKey: "access_token") else {
            showAlert(title: "Ошибка", message: "Сессия недействительна.")
            return
        }

        let urlString = "http://localhost:8080/api/users/\(userId)"
        guard let url = URL(string: urlString) else {
            showAlert(title: "Ошибка", message: "Некорректный URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

//        print("📤 Отправка запроса DELETE на \(urlString)")
//        print("🔐 Токен: \(token.prefix(16))...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка сети:", error.localizedDescription)
                    self.showAlert(title: "Ошибка", message: "Сетевая ошибка: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Нет ответа от сервера")
                    self.showAlert(title: "Ошибка", message: "Нет ответа от сервера.")
                    return
                }

//                print("📥 Ответ от сервера: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    self.handleSuccessfulDeletion()
                } else {
                    self.showAlert(title: "Ошибка", message: "Не удалось удалить аккаунт. Код: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    private func handleSuccessfulDeletion() {
        
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.synchronize()

        
        if let welcomeVC = storyboard?.instantiateViewController(withIdentifier: "wellcome") {
            welcomeVC.modalPresentationStyle = .fullScreen
            present(welcomeVC, animated: true, completion: nil)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
