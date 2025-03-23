//
//  TicketsViewController.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/25/24.
//

import UIKit

struct Ticket: Codable {
    let id: String
    let user_id: String
    let route_id: String?
    let price: Int
    let status: String
    let payment_status: String
    let qr_code: String
    let created_at: String
    let slot: Slot
    let path: String
    let paid: Bool
    let qrCodeBase64: String?

    enum CodingKeys: String, CodingKey {
        case id, user_id, route_id, price, status, payment_status, qr_code, created_at, slot, path, paid, qrCodeBase64
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        user_id = try container.decode(String.self, forKey: .user_id)
        route_id = try container.decodeIfPresent(String.self, forKey: .route_id)
        price = try container.decode(Int.self, forKey: .price)
        status = try container.decode(String.self, forKey: .status)
        payment_status = try container.decode(String.self, forKey: .payment_status)
        qr_code = try container.decode(String.self, forKey: .qr_code)
        created_at = try container.decode(String.self, forKey: .created_at)
        
        
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot) ?? Slot.defaultSlot()
        path = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
        paid = try container.decodeIfPresent(Bool.self, forKey: .paid) ?? false
        qrCodeBase64 = try container.decodeIfPresent(String.self, forKey: .qrCodeBase64) ?? ""
    }
}

struct Slot: Codable {
    let id: String
    let departure: String
    let destination: String
    let start_date: Date
    let end_date: Date
    let available_seats: Int
    let bus_id: String
    let price: Int
    let created_at: String
    let updated_at: String
    let carNumber: String?
    let availableSeats: Int?

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    enum CodingKeys: String, CodingKey {
        case id, departure, destination, start_date = "start_date", end_date = "end_date", available_seats, bus_id, price, created_at, updated_at, carNumber, availableSeats
    }

    init(id: String = "default_id",
         departure: String = "Unknown",
         destination: String = "Unknown",
         start_date: Date = Date(),
         end_date: Date = Date(),
         available_seats: Int = 0,
         bus_id: String = "default_bus_id",
         price: Int = 0,
         created_at: String = "",
         updated_at: String = "",
         carNumber: String? = nil,
         availableSeats: Int? = nil) {
        self.id = id
        self.departure = departure
        self.destination = destination
        self.start_date = start_date
        self.end_date = end_date
        self.available_seats = available_seats
        self.bus_id = bus_id
        self.price = price
        self.created_at = created_at
        self.updated_at = updated_at
        self.carNumber = carNumber
        self.availableSeats = availableSeats
    }

    static func defaultSlot() -> Slot {
        return Slot()
    }
}


class UserTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
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

        cell.Path.text = "\(ticket.slot.departure) - \(ticket.slot.destination)"
        cell.Status.text = ticket.paid ? "Paid" : "Unpaid"
        
        cell.CarNumber.text = ticket.slot.carNumber
        

        return cell
    }
    
    
    
    enum TicketType {
        case past
        case upcoming
    }

    var currentTicketType: TicketType = .past
    
    let pastTickets: [Ticket] = []

    let upcomingTickets: [Ticket] = []
    
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
