//
//  SellerCatProductsCell.swift
//  SaharaGo
//
//  Created by Ritesh on 16/12/20.
//

import UIKit

class SellerCatProductsCell: UITableViewCell {

    @IBOutlet var cellDeleteBtn: UIButton!
    @IBOutlet var cellDiscountPercentLbl: UILabel!
    @IBOutlet var cellStockLbl: UILabel!
    @IBOutlet var cellNewPrice: UILabel!
    @IBOutlet var cellOldPrice: UILabel!
    @IBOutlet var cellEditBtn: UIButton!
    @IBOutlet var cellTitleLbl: UILabel!
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
