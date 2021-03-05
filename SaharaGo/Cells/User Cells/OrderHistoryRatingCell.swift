//
//  OrderHistoryRatingCell.swift
//  SaharaGo
//
//  Created by Ritesh on 20/01/21.
//

import UIKit
import Cosmos

class OrderHistoryRatingCell: UITableViewCell {
    
    @IBOutlet var productRatingView: CosmosView!
    @IBOutlet var ratingView: UIView!

    @IBOutlet weak var cellRatingBtn: UIButton!
    @IBOutlet var celldesclbl: UILabel!
       @IBOutlet var cellPriceLbl: UILabel!
       @IBOutlet var cellTitleLbl: UILabel!
       @IBOutlet var cellImg: UIImageView!
       @IBOutlet var orderDateLbl: UILabel!
       @IBOutlet var orderIdLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
