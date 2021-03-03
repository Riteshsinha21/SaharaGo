//
//  CustomButtonClass.swift
//  SaharaGo
//
//  Created by ChawTech Solutions on 26/02/21.
//

import UIKit

class CustomButtonClass: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required public init?(coder aDecoder: NSCoder) {

            super.init(coder: aDecoder)

        guard let countryColorStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.COUNTRY_COLOR_CODE) as? String else {return}
        guard let rgba = countryColorStr.slice(from: "(", to: ")") else { return }
        let myStringArr = rgba.components(separatedBy: ",")
        self.backgroundColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 17)
//        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
//            self.backgroundColor = UIColor.whiteColor()
//            self.layer.borderColor = UIColor.blackColor().CGColor

        }

}
