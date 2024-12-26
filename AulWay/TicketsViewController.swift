//
//  TicketsViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/25/24.
//

import UIKit

struct Slot {
    let id: String
    let start_date: Date
    let end_date: Date
    let depature: String
    let deatinatoin: String
    let price: Int
    let total_tickets: Int
    let carNumber: String
}

struct Ticket {
    let slot: Slot
    let paid: Bool
    let user_id: String
}



class TicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tickets.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTicketType {
        case .past:
            return pastTickets.count
        case .upcoming:
            return upcomingTickets.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell

        let ticket: Ticket
        switch currentTicketType {
        case .past:
            ticket = pastTickets[indexPath.row]
        case .upcoming:
            ticket = upcomingTickets[indexPath.row]
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        cell.Date.text = dateFormatter.string(from: ticket.slot.start_date)


        let duration = ticket.slot.end_date.timeIntervalSince(ticket.slot.start_date) / 3600
        cell.Duration.text = String(format: "%.2f hours", duration)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        cell.Time.text = "\(timeFormatter.string(from: ticket.slot.start_date)) - \(timeFormatter.string(from: ticket.slot.end_date))"

        cell.Path.text = "\(ticket.slot.depature) - \(ticket.slot.deatinatoin)"
        cell.Status.text = ticket.paid ? "Paid" : "Unpaid"
        
        cell.CarNumber.text = ticket.slot.carNumber
        

        return cell
    }
    
    enum TicketType {
        case past
        case upcoming
    }

    var currentTicketType: TicketType = .past
    
    let pastTickets: [Ticket] = [
        Ticket(
            slot: Slot(
                id: "1",
                start_date: makeDate(from: "2024-12-01T10:00:00Z"),
                end_date: makeDate(from: "2024-12-01T14:00:00Z"),
                depature: "New York",
                deatinatoin: "Los Angeles",
                price: 150,
                total_tickets: 200,
                carNumber: "505BES05"
            ),
            paid: true,
            user_id: "user1"
        ),
        Ticket(
            slot: Slot(
                id: "2",
                start_date: makeDate(from: "2024-11-25T08:00:00Z"),
                end_date: makeDate(from: "2024-11-25T12:00:00Z"),
                depature: "San Francisco",
                deatinatoin: "Seattle",
                price: 100,
                total_tickets: 150,
                carNumber: "001OVE02"
            ),
            paid: false,
            user_id: "user2"
        ),
        Ticket(
            slot: Slot(
                id: "3",
                start_date: makeDate(from: "2024-12-10T09:30:00Z"),
                end_date: makeDate(from: "2024-12-10T13:30:00Z"),
                depature: "Chicago",
                deatinatoin: "Houston",
                price: 120,
                total_tickets: 180,
                carNumber: "777BAY07"
            ),
            paid: true,
            user_id: "user3"
        )
    ]

    
    let upcomingTickets: [Ticket] = [
        Ticket(
            slot: Slot(
                id: "11",
                start_date: makeDate(from: "2025-01-05T09:00:00Z"),
                end_date: makeDate(from: "2025-01-05T13:00:00Z"),
                depature: "New York",
                deatinatoin: "San Francisco",
                price: 200,
                total_tickets: 250,
                carNumber: "222EEE02"
            ),
            paid: true,
            user_id: "user1"
        ),
        Ticket(
            slot: Slot(
                id: "12",
                start_date: makeDate(from: "2025-02-10T14:00:00Z"),
                end_date: makeDate(from: "2025-02-10T18:00:00Z"),
                depature: "Chicago",
                deatinatoin: "Miami",
                price: 180,
                total_tickets: 220,
                carNumber: "10HAH01"
            ),
            paid: false,
            user_id: "user2"
        ),
        Ticket(
            slot: Slot(
                id: "13",
                start_date: makeDate(from: "2025-03-15T07:30:00Z"),
                end_date: makeDate(from: "2025-03-15T11:30:00Z"),
                depature: "Houston",
                deatinatoin: "Denver",
                price: 160,
                total_tickets: 180,
                carNumber: "12QOR03"
            ),
            paid: true,
            user_id: "user3"
        )
    ]
    
    @IBAction func switchTicketType(_ sender: UIButton) {

        if sender == upcomingButton {
            currentTicketType = .upcoming
        
            upcomingButton.backgroundColor = UIColor.clear
            upcomingButton.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
            upcomingButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            upcomingButton.layer.cornerRadius = pastButton.frame.height / 2
            upcomingButton.clipsToBounds = true
            
            pastButton.backgroundColor = UIColor.clear
            pastButton.backgroundColor = #colorLiteral(red: 0.4941176471, green: 0.5137254902, blue: 0.4901960784, alpha: 1)
            pastButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            pastButton.layer.cornerRadius = upcomingButton.frame.height / 2
            pastButton.clipsToBounds = true
        } else {
            currentTicketType = .past
            
            pastButton.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
            pastButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            pastButton.layer.cornerRadius = pastButton.frame.height / 2
            pastButton.clipsToBounds = true
            
            
            upcomingButton.backgroundColor = #colorLiteral(red: 0.4941176471, green: 0.5137254902, blue: 0.4901960784, alpha: 1)
            upcomingButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            upcomingButton.layer.cornerRadius = upcomingButton.frame.height / 2
            upcomingButton.clipsToBounds = true
            
        }
        tickets.reloadData()
    }
    
    @IBOutlet weak var tickets: UITableView!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var pastButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pastButton.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
        pastButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        pastButton.layer.cornerRadius = pastButton.frame.height / 2
        pastButton.clipsToBounds = true
        
        
        upcomingButton.backgroundColor = #colorLiteral(red: 0.4941176471, green: 0.5137254902, blue: 0.4901960784, alpha: 1)
        upcomingButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        upcomingButton.layer.cornerRadius = upcomingButton.frame.height / 2
        upcomingButton.clipsToBounds = true

        tickets.delegate = self
        tickets.dataSource = self
    }

}

func makeDate(from string: String) -> Date {
    let dateFormatter = ISO8601DateFormatter()
    return dateFormatter.date(from: string)!
}
