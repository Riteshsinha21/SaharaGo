//
//  LoginVC.swift
//  SaharaGo
//
//  Created by Ritesh on 04/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class LoginVC: UIViewController {

    @IBOutlet var passwordTxt: SkyFloatingLabelTextField!
    @IBOutlet var mailTxt: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        if self.mailTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Email.")
            return
        } else if self.passwordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Password.")
            return
        }
        self.loginApiCall()
    }
    
    @IBAction func forgotPswrdAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loginApiCall() {
        
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            if let objFcmKey = UserDefaults.standard.object(forKey: "fcm_key") as? String
            {
                fcmKey = objFcmKey
            }
            else
            {
                //                fcmKey = ""
                fcmKey = "abcdef"
            }
            
            let param:[String:Any] = [ "emailMobile": self.mailTxt.text!,"password":self.passwordTxt.text!, "fcmKey": fcmKey,"channel":"iOS"]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_LOGIN, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
                    UserDefaults.standard.setValue(json["type"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_TYPE)
                    UserDefaults.standard.setValue(json["userId"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_ID)
                    self.updateFcmApi()
                    isLogin = "yes"
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
                    } else if isWishlistTab == "yes" {
                        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if isProfileTab == "yes" {
                        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if isHome == "yes" {
                        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
//                        isSignUp = "yes"
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if isNotification == "yes" {
                        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
                        isLogin = "yes"
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
    
    func updateFcmApi() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)

            let param:[String:String] = ["fcmKey": UserDefaults.standard.object(forKey: "fcm_key") as! String]
                        
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_UPDATE_FCM, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    
                } else {
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
