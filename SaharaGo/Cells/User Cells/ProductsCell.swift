//
//  ProductsCell.swift
//  SaharaGo
//
//  Created by Ritesh on 08/12/20.
//

import UIKit

class ProductsCell: UITableViewCell {

    @IBOutlet var cellImg: UIImageView!
    @IBOutlet var cellNewPrice: UILabel!
    @IBOutlet var cellDiscountLbl: UILabel!
    @IBOutlet var cellBtn: UIButton!
    @IBOutlet var cellStockLbl: UILabel!
    @IBOutlet var cellOldPrice: UILabel!
    @IBOutlet var cellTitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
