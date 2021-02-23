//
//  ProductsCategoriesCell.swift
//  SaharaGo
//
//  Created by Ritesh on 15/12/20.
//

import UIKit

class ProductsCategoriesCell: UITableViewCell {

    @IBOutlet var cellImg: UIImageView!
    @IBOutlet var cellLbl: UILabel!
    @IBOutlet var cellSublbl: UILabel!
    @IBOutlet var cellBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
