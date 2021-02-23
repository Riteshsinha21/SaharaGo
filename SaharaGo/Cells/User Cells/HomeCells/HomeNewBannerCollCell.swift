//
//  HomeNewBannerCollCell.swift
//  SaharaGo
//
//  Created by Ritesh on 18/12/20.
//

import UIKit

class HomeNewBannerCollCell: UICollectionViewCell {
    
    @IBOutlet var cellImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImg.clipsToBounds = true
        cellImg.layer.cornerRadius = 5
    }
}
