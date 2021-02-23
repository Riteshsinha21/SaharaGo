//
//  NotificationsCell.swift
//  SaharaGo
//
//  Created by Ritesh on 14/01/21.
//

import UIKit

class NotificationsCell: UITableViewCell {

    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellBody: UILabel!
    @IBOutlet var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
