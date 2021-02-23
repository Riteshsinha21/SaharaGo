
//
//  SellerProductsCell.swift
//  SaharaGo
//
//  Created by Ritesh on 08/02/21.
//

import UIKit

class SellerProductsCell: UITableViewCell {
    
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
