//
//  SellerForgotPswrdOTPVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class SellerForgotPswrdOTPVC: UIViewController {

    @IBOutlet var otptxt: SkyFloatingLabelTextField!
    
    @IBOutlet var newPasswordTxt: SkyFloatingLabelTextField!
    @IBOutlet var confirmPasswordTxt: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        if self.otptxt.text!.isEmpty {
            self.view.makeToast("Please Enter OTP.")
            return
        } else if self.newPasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter New Password.")
            return
        } else if self.confirmPasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Confirm Password.")
            return
        } else if self.newPasswordTxt.text!.count < 7 || self.newPasswordTxt.text!.count > 16 {
            self.view.makeToast("Password should have 7 to 16 characters.")
            return
        } else if self.confirmPasswordTxt.text! != self.newPasswordTxt.text! {
            self.view.makeToast("Passwords not matched.")
            return
        }
        
        self.forgotPswrdOtpVerifyAPI()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil )
    }
    
    func forgotPswrdOtpVerifyAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "otpId": UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)!,"otp":self.otptxt.text!,"password":self.newPasswordTxt.text!]
                        
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_FORGOT_PASSWORD_OTP_VERIFY, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.presentingViewController?
                        .presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    self.view.makeToast("\(json["message"].stringValue)")
                    //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
