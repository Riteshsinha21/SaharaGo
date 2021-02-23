//
//  CartCell.swift
//  SaharaGo
//
//  Created by Ritesh on 16/12/20.
//

import UIKit

class CartCell: UITableViewCell {

    @IBOutlet var cellImg: UIImageView!
    @IBOutlet var cellTitleLbl: UILabel!
    @IBOutlet var cellPriceLbl: UILabel!
    
    @IBOutlet var cellCountLbl: UILabel!
    @IBOutlet var cellDescLbl: UILabel!
    
    @IBOutlet var cellDecrementBtn: UIButton!
    
    @IBOutlet var cellIncrementBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setCartData(_ info: cartProductListStruct) {
        
        self.cellTitleLbl.text = info.name
        self.cellPriceLbl.text = "\(info.currency) \(info.discountedPrice)"
        self.cellDescLbl.text = info.description
        self.cellCountLbl.text = info.quantity
        self.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.images)"), placeholderImage: UIImage(named: "edit cat_img"))
        
    }

}
