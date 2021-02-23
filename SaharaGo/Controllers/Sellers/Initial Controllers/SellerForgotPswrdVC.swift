//
//  SellerForgotPswrdVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class SellerForgotPswrdVC: UIViewController {

    @IBOutlet var mailTxt: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if self.mailTxt.text!.isEmpty {
            self.view.makeToast("Please Enter your Email.")
            return
        }
        self.forgotPswrdApi()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil )
    }
    
    func forgotPswrdApi() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = ["emailMobile": self.mailTxt.text!]
                        
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_FORGOT_PASSWORD, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    UserDefaults.standard.setValue(json["otpId"].stringValue, forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)
                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerForgotPswrdOTPVC") as! SellerForgotPswrdOTPVC
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
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
