//
//  ForgotPasswordOTPVC.swift
//  SaharaGo
//
//  Created by Ritesh on 17/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class ForgotPasswordOTPVC: UIViewController {

    @IBOutlet var otpTxt: SkyFloatingLabelTextField!
    @IBOutlet var passwordTxt: SkyFloatingLabelTextField!
    @IBOutlet var confirmPswrdTxt: SkyFloatingLabelTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        if self.otpTxt.text!.isEmpty {
            self.view.makeToast("Please Enter OTP.")
            return
        } else if self.passwordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter New Password.")
            return
        } else if self.confirmPswrdTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Confirm Password.")
            return
        } else if self.passwordTxt.text!.count < 7 || self.passwordTxt.text!.count > 16 {
            self.view.makeToast("Password should have 7 to 16 characters.")
            return
        } else if self.confirmPswrdTxt.text! != self.passwordTxt.text! {
            self.view.makeToast("Passwords not matched.")
            return
        }
        
        self.forgotPswrdOtpVerifyAPI()
    }
    
    func forgotPswrdOtpVerifyAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "otpId": UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)!,"otp":self.otpTxt.text!,"password":self.passwordTxt.text!]
                        
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_FORGOT_PASSWORD_OTP_VERIFY, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                    }
                }
                else {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
