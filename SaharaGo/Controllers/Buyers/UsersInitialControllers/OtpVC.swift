//
//  OtpVC.swift
//  SaharaGo
//
//  Created by Ritesh on 04/12/20.
//

import UIKit
import OTPFieldView

class OtpVC: UIViewController {
        
    @IBOutlet var continueBtn: UIButton!
    @IBOutlet var otpView: OTPFieldView!
    
    var otpEntered:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupOtpView()
        
    }
    
    func setupOtpView(){
        self.otpView.fieldsCount = 6
        self.otpView.fieldBorderWidth = 1
        self.otpView.defaultBorderColor = UIColor.darkGray
        self.otpView.filledBorderColor = UIColor.black
        self.otpView.cursorColor = UIColor.black
        self.otpView.displayType = .roundedCorner
        self.otpView.fieldSize = 40
        self.otpView.separatorSpace = 8
        self.otpView.shouldAllowIntermediateEditing = false
        self.otpView.delegate = self
        self.otpView.initializeUI()
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func continueAction(_ sender: Any) {
        
        if self.otpEntered.count == 0 {
            self.view.makeToast("Please enter OTP.")
            return
        }
        self.signupOtpVerifyApiCall()
    }
    
    @IBAction func resendAction(_ sender: Any) {
    }
    
        func signupOtpVerifyApiCall() {
            if Reachability.isConnectedToNetwork() {
                showProgressOnView(appDelegateInstance.window!)
                
            let param:[String:Any] = [ "otpId": UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)!,"otp":self.otpEntered,"channel":"iOS"]
                ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_SIGNUP_OTP_VERIFY, successBlock: { (json) in
                    print(json)
                    hideAllProgressOnView(appDelegateInstance.window!)
                    let success = json["success"].stringValue
                    if success == "true"
                    {
                        //save data in userdefault..
                        UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
                        UserDefaults.standard.setValue(json["type"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_TYPE)
                        UserDefaults.standard.setValue(json["userId"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_ID)
    //
                        self.navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
                            if vc.isKind(of: OtpVC.self) || vc.isKind(of: SignUpVC.self) || vc.isKind(of: LoginVC.self) || vc.isKind(of: ForgotPasswordVC.self) {
                                return true
                            } else {
                                return false
                            }
                        })
                        
                        if isWishlist == "yes" {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }  else if isWishlistTab == "yes" {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else if isProfileTab == "yes" {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else if isHome == "yes" {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
                            isSignUp = "yes"
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else if isNotification == "yes" {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
                            isSignUp = "yes"
                            self.navigationController?.pushViewController(vc, animated: true)
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

extension OtpVC: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        if hasEntered {
            self.continueBtn.alpha = 1.0
            self.continueBtn.isUserInteractionEnabled = true
            
        }
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        self.otpEntered = otpString
        print("OTPString: \(otpString)")
    }
}
