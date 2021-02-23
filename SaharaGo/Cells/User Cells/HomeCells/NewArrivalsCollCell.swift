//
//  NewArrivalsCollCell.swift
//  SaharaGo
//
//  Created by Ashish Nimbria on 12/22/20.
//

import UIKit

class NewArrivalsCollCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10.0, height: 10.0)).cgPath

//        self.productImageView.layer.mask = maskLayer
    }
    
    var product: topDeals_Struct?{
        didSet{
            
            guard let product = self.product else { return }
            self.productTitleLabel.text = product.name
//            if (product.metaData?.images!.count)! > 0 {
//
//                if let imageUrl = product.metaData?.images?[0]{
//
//                    let imgUrl = FILE_BASE_URL + "/" + imageUrl
//                    print(imgUrl)
//
//                    self.productImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "edit cat_img"))
//
//                }
//
//            }else {
//                self.productImageView.image = UIImage(named: "edit cat_img")
//            }

            if (product.images!.count) > 0 {
                
                if let imageUrl = product.images?[0]{
                    
                    let imgUrl = FILE_BASE_URL + "/" + imageUrl
                    print(imgUrl)
                    
                    self.productImageView.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "edit cat_img"))
                    
                }
                 
            }else {
                self.productImageView.image = UIImage(named: "edit cat_img")
            }

        }
    }
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
}
