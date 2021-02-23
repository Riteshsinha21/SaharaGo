//
//  CategoriesCollCell.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit

class CategoriesCollCell: UICollectionViewCell {
    
    var product: topDeals_Struct?{
        didSet{
            
            guard let product = self.product else { return }
            self.cellLbl.text = product.name
//            if (product.metaData?.images!.count)! > 0 {
//
//                if let imageUrl = product.metaData?.images?[0]{
//
//                    let imgUrl = FILE_BASE_URL + "/" + imageUrl
//                    print(imgUrl)
//
//                    self.cellImg.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "edit cat_img"))
//
//                }
//
//
//            } else {
//                self.cellImg.image = UIImage(named: "edit cat_img")
//            }
            
            if (product.images!.count) > 0 {
                
                if let imageUrl = product.images?[0]{
                    
                    let imgUrl = FILE_BASE_URL + "/" + imageUrl
                    print(imgUrl)

                    self.cellImg.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "edit cat_img"))
                    
                }
                
                
            } else {
                self.cellImg.image = UIImage(named: "edit cat_img")
            }
            
            
        }
    }
    
    @IBOutlet var cellLbl: UILabel!
    @IBOutlet var cellImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        cellImg.maskToBounds = true
//        cellImg.clipsToBounds = true
    }
}
