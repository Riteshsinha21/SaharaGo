//
//  SellerChangePasswordVC.swift
//  SaharaGo
//
//  Created by Ritesh on 28/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class SellerChangePasswordVC: UIViewController {

    @IBOutlet var confirmPasswordTxt: SkyFloatingLabelTextField!
    @IBOutlet var newPasswordTxt: SkyFloatingLabelTextField!
    @IBOutlet var oldPasswordTxt: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if self.oldPasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Old Password.")
            return
        } else if self.newPasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Old Password.")
            return
        } else if self.newPasswordTxt.text!.count < 7 || self.newPasswordTxt.text!.count > 16 {
            self.view.makeToast("Password should have 7 to 16 characters.")
            return
        } else if self.confirmPasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Confirm your Password")
            return
        } else if self.confirmPasswordTxt.text! != self.newPasswordTxt.text! {
            self.view.makeToast("Passwords not matched.")
            return
        }
        self.changePasswordApi()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func changePasswordApi() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = ["oldPassword": self.oldPasswordTxt.text!, "newPassword": self.newPasswordTxt.text!]
                        
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_CHANGE_PASSWORD, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
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
