//
//  TestViewController.swift
//  AulWay
//
//  Created by Aruzhan Kaharmanova on 27.02.2025.
//

import UIKit

class TestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var jsonData: [[String: Any]] = [] // Stores the parsed JSON response
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return jsonData.count // Each ticket will be a section
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonData[section].count // Each key-value pair is a row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let ticket = jsonData[indexPath.section]
        let keys = Array(ticket.keys)
        let key = keys[indexPath.row]
        let value = ticket[key] ?? "N/A"

        cell.textLabel?.text = "\(key): \(value)"
        cell.textLabel?.numberOfLines = 0 // Allow multi-line display
        
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section + 1)"
    }
}
