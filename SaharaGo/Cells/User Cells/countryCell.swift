//
//  countryCell.swift
//  SaharaGo
//
//  Created by Ritesh on 16/12/20.
//

import UIKit

class countryCell: UITableViewCell {

    @IBOutlet var cellLbl: UILabel!
    @IBOutlet var cellImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
