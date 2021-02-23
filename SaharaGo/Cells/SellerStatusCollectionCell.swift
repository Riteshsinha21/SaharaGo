//
//  SellerStatusCollectionCell.swift
//  SaharaGo
//
//  Created by Ashish Nimbria on 1/4/21.
//

import UIKit

class SellerStatusCollectionCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                UIView.animate(withDuration: 0.5) {
                     self.statusBtn.layer.cornerRadius = 15
                     self.statusBtn.backgroundColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
                     self.statusBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
                     self.statusBtn.borderWidth = 1
                     self.statusBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                }
            }
            else {
                UIView.animate(withDuration: 0.5) {
                     
                    self.statusBtn.layer.cornerRadius = 15
                    self.statusBtn.backgroundColor = .white
                    self.statusBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
                    self.statusBtn.borderWidth = 1
                    self.statusBtn.setTitleColor(#colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1), for: .normal)
                    
                }
            }
        }
    }
    
    @IBOutlet weak var statusBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusBtn.maskToBounds = false
        statusBtn.layer.cornerRadius = 15
        statusBtn.backgroundColor = .white
        statusBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
        statusBtn.borderWidth = 1
        statusBtn.setTitleColor(#colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1), for: .normal)
    }

}
