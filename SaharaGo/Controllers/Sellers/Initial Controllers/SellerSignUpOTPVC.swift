//
//  SellerSignUpOTPVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit
import SkyFloatingLabelTextField
import Toast_Swift

class SellerSignUpOTPVC: UIViewController {

    @IBOutlet var mailPinTxt: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        if self.mailPinTxt.text!.isEmpty {
            self.view.makeToast("Please Enter OTP.")
            return
        }
        self.signupOtpVerifyApiCall()
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func signupOtpVerifyApiCall() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
        let param:[String:Any] = [ "otpId": UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)!,"otp":self.mailPinTxt.text!,"channel":"iOS"]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_SIGNUP_OTP_VERIFY, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
                    UserDefaults.standard.setValue(json["type"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_TYPE)
                    
                    let tabbarVC = self.loadTabBar()
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                    tabbarVC.modalPresentationStyle = .fullScreen
                    UIApplication.topViewController()?.present(tabbarVC, animated: true, completion: nil)
                    //self.present(tabbarVC, animated: false, completion: nil)
                    
//                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
//                    self.navigationController?.pushViewController(vc, animated: true)

                    
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
