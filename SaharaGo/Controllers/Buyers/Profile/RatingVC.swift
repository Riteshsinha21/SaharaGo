//
//  RatingVC.swift
//  SaharaGo
//
//  Created by Ritesh on 20/01/21.
//

import UIKit
import Cosmos

class RatingVC: UIViewController {

    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var reviewTxtview: UITextView!
    
    var rating = 0.00
    var orderInfo = current_order_Address_main_struct()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //ratingView.settings.updateOnTouch = true
        ratingView.settings.fillMode = .precise
        ratingView.rating = 0.00
        
        ratingView.didFinishTouchingCosmos = { rating in
            
            self.rating = rating
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        if orderInfo.cartMetaData[0].isRated {
            self.ratingView.settings.updateOnTouch = false
            self.reviewTxtview.isUserInteractionEnabled = false
            
            self.reviewTxtview.text = orderInfo.cartMetaData[0].userReview
            self.rating = Double(orderInfo.cartMetaData[0].userRating)
            self.ratingView.rating = Double(orderInfo.cartMetaData[0].userRating)
        }
        
    }
    
    @IBAction func notNowAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func subitAction(_ sender: Any) {
        if orderInfo.cartMetaData[0].isRated {
            self.view.makeToast("You can't edit your ratings for now.")
        } else {
            if self.rating == 0.00 {
                self.view.makeToast("Please give Star rating as per your experience.")
                return
            }
            
            self.giveRatingApiCall()
        }
    }
    

    func giveRatingApiCall() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "fromId": UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.USER_ID) as! String,"toId":self.orderInfo.cartMetaData[0].itemId,"rating":self.rating, "review": self.reviewTxtview.text!,"orderId": self.orderInfo.orderId]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GIVE_RATING, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    self.view.makeToast(json["message"].stringValue)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
                else {
                    self.view.makeToast("\(json["message"].stringValue)")
                    // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
}
