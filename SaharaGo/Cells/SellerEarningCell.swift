//
//  SellerEarningCell.swift
//  SaharaGo
//
//  Created by Ritesh on 03/02/21.
//

import UIKit

class SellerEarningCell: UITableViewCell {

    @IBOutlet var cellPaidLbl: UILabel!
    @IBOutlet var cellOrderIdLbl: UILabel!
    @IBOutlet var cellTransactionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
