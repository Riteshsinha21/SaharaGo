//
//  SellerLoginVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class SellerLoginVC: UIViewController {

    @IBOutlet var mailtxt: SkyFloatingLabelTextField!
    @IBOutlet var passwordTxt: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = userStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
        UIApplication.shared.delegate!.window!!.rootViewController = viewController
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerForgotPswrdVC") as! SellerForgotPswrdVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if self.mailtxt.text!.isEmpty {
            self.view.makeToast("Please Enter Email.")
            return
        } else if self.passwordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Password.")
            return
        }
        self.loginApiCall()
    }
    
    @IBAction func signupAction(_ sender: Any) {
        
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerSignUpVC") as! SellerSignUpVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
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
            
            let param:[String:Any] = [ "emailMobile": self.mailtxt.text!,"password":self.passwordTxt.text!, "fcmKey": fcmKey,"channel":"iOS"]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_LOGIN_API, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
                    UserDefaults.standard.setValue(json["type"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_TYPE)
                    
                    //let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//                    let tabbarVC = self.loadTabBar()
//                    self.emailIdTxt.resignFirstResponder()
//                    self.passwordTxt.resignFirstResponder()
//                     UserDefaults.standard.set(true, forKey: "launchedBefore")
//                    tabbarVC.modalPresentationStyle = .fullScreen
//                    self.present(tabbarVC, animated: false, completion: nil)
//
//                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SourcingVC") as! SourcingVC
//                    vc.modalPresentationStyle = .fullScreen
//                    self.present(vc, animated: true, completion: nil)
                    let tabbarVC = self.loadTabBar()
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                    tabbarVC.modalPresentationStyle = .fullScreen
                    self.present(tabbarVC, animated: false, completion: nil)
                    
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
