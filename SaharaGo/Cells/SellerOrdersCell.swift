//
//  SellerOrdersCell.swift
//  SaharaGo
//
//  Created by Ashish Nimbria on 1/4/21.
//

import UIKit

class SellerOrdersCell: UITableViewCell {

    @IBOutlet var statusBtn: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
