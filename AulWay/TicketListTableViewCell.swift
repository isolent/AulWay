import UIKit

class TicketListTableViewCell: UITableViewCell {

    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var favourite: UIButton!
    @IBOutlet weak var date: UILabel!

    var onFavouriteTapped: (() -> Void)?
    private var isFavorite: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCellUI()
        favourite?.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }

    private func configureCellUI() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.backgroundColor = UIColor(red: 0.49, green: 0.51, blue: 0.49, alpha: 1.0)
        favourite?.tintColor = .white
    }

    @objc private func favoriteTapped() {
        onFavouriteTapped?()
    }

    func updateFavouriteIcon(isFavourite: Bool) {
        let imageName = isFavourite ? "heart.fill" : "heart"
        let image = UIImage(systemName: imageName)
        favourite?.setImage(image, for: .normal)
    }

    func configure(with slot: Slot) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = "\(dateFormatter.string(from: slot.start_date)) - \(dateFormatter.string(from: slot.end_date))"
        time.text = timeString

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: slot.start_date, to: slot.end_date)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        duration.text = "\(hours)h \(minutes)m"

        route.text = "\(slot.departure) → \(slot.destination)"
        price.text = "\(slot.price) ₸"

        dateFormatter.dateFormat = "d MMM"
        self.date?.text = dateFormatter.string(from: slot.start_date)

        isFavorite = slot.isFavourite ?? false
        updateFavouriteIcon(isFavourite: isFavorite)
    }
}
