//
//  OrderHistoryCell.swift
//  SaharaGo
//
//  Created by Ritesh on 06/01/21.
//

import UIKit
import Cosmos

class OrderHistoryCell: UITableViewCell {

    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var cancelView: UIView!
    @IBOutlet var cellCancelAction: UIButton!
    @IBOutlet var cellTrackBtn: UIButton!
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
