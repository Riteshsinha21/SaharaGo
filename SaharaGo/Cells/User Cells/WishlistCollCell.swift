//
//  wishlistCollCell.swift
//  SaharaGo
//
//  Created by Ritesh on 07/12/20.
//

import UIKit

class WishlistCollCell: UICollectionViewCell {
    
    @IBOutlet var cellProductimg: UIImageView!
    @IBOutlet var cellProductName: UILabel!
    @IBOutlet var cellProductCost: UILabel!
    
    @IBOutlet var cellBtnLbl: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellBtnLbl.maskToBounds = false
        cellBtnLbl.layer.borderWidth = 1
        cellBtnLbl.layer.borderColor = UIColor.black.cgColor
        
        cellProductimg.clipsToBounds = true
        cellProductimg.layer.cornerRadius = 10
    }
}
