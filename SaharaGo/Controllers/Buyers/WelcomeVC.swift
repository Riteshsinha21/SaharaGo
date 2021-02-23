//
//  WelcomeVC.swift
//  SaharaGo
//
//  Created by Ritesh on 17/12/20.
//

import UIKit

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startBuyingAction(_ sender: Any) {
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = userStoryboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! TabVC
        UIApplication.shared.delegate!.window!!.rootViewController = viewController
    }
    
    @IBAction func startSellingAction(_ sender: Any) {
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let viewController = userStoryboard.instantiateViewController(withIdentifier: "SellerLoginVC") as! SellerLoginVC
        UIApplication.shared.delegate!.window!!.rootViewController = viewController
    }
    

}
