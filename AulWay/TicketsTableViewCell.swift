//
//  TicketsTableViewCell.swift
//  AulWay
//
//  Created by Dilyara Mukhambetova on 12/25/24.
//

import UIKit

class TicketsTableViewCell: UITableViewCell {

    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Duration: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var CarNumber: UILabel!
    @IBOutlet weak var Path: UILabel!
    override func awakeFromNib() {
       super.awakeFromNib()
       configureCell()
   }

   private func configureCell() {
       
       self.contentView.layer.cornerRadius = 30
       self.contentView.layer.masksToBounds = true
       self.contentView.layer.borderWidth = 1
       self.contentView.layer.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)
       self.contentView.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
   }
}
