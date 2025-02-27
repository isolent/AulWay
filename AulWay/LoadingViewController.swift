import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var busImageView: UIImageView!
    
    @IBOutlet weak var Path: UILabel!
    @IBOutlet weak var DateInfo: UILabel!
    
    var fromLocation: String = ""
    var toLocation: String = ""
    var travelDate: Date = Date()
    var passengerCount: Int = 1
    var slotList: [Slot] = []
    
    var animationTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Path.text = "\(fromLocation) → \(toLocation)"
        DateInfo.text = DateFormatter.localizedString(from: travelDate, dateStyle: .medium, timeStyle: .none)


        progressView.progress = 0.0


        resetBusPosition()


        startBusAnimation(duration: 5.0)
    }

    
    func resetBusPosition() {
        let startX = progressView.frame.origin.x
        busImageView.frame.origin.x = startX
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTicketList" {
            if let ticketListVC = segue.destination as? SearchResultViewController {
                ticketListVC.fromLocation = fromLocation
                ticketListVC.toLocation = toLocation
                ticketListVC.travelDate = travelDate
//                ticketListVC.passengerCount = passengerCount
            }
        }
        
        
    }

        
        func startBusAnimation(duration: TimeInterval) {

            progressView.progress = 0.0
            resetBusPosition()


            let totalSteps = Int(duration * 60)
            var currentStep = 0


            let progressWidth = progressView.frame.width
            let busWidth = busImageView.frame.width
            let startX = progressView.frame.origin.x
            let destinationX = startX + progressWidth - busWidth


            animationTimer?.invalidate()


            animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
                currentStep += 1
                let progress = Float(currentStep) / Float(totalSteps)

                
                self.progressView.progress = progress

                
                let newX = startX + CGFloat(progress) * (destinationX - startX)
                self.busImageView.frame.origin.x = newX

            
                if currentStep >= totalSteps {
                    timer.invalidate()
                    self.performSegue(withIdentifier: "showTicketList", sender: self)
                }
            }
        }
}

