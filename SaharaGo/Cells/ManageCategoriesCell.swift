//
//  ManageCategoriesCell.swift
//  SaharaGo
//
//  Created by Ritesh on 12/01/21.
//

import UIKit

class ManageCategoriesCell: UITableViewCell {

    @IBOutlet var cellReasonBtn: UIButton!
    @IBOutlet var cellRejectImg: UIImageView!
    @IBOutlet var celleditbtn: UIButton!
    @IBOutlet var cellDescLbl: UILabel!
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
