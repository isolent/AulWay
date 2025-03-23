//
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/25/24.
//

import UIKit


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
