//
//  ProductRatingCell.swift
//  SaharaGo
//
//  Created by Ritesh on 27/01/21.
//

import UIKit
import Cosmos

class ProductRatingCell: UITableViewCell {

    @IBOutlet var cellRatingView: CosmosView!
    @IBOutlet var cellDescLbl: UILabel!
    @IBOutlet var cellName: UILabel!
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
