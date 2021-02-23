//
//  ChangePasswordVC.swift
//  SaharaGo
//
//  Created by Ritesh on 22/12/20.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet var confirmPasswordtxt: UITextField!
    @IBOutlet var newpasswordTxt: UITextField!
    @IBOutlet var oldPasswordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    

    @IBAction func submitAction(_ sender: Any) {
        if self.oldPasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Old Password.")
            return
        } else if self.newpasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter New Password.")
            return
        }else if self.newpasswordTxt.text!.count < 7 || self.newpasswordTxt.text!.count > 16 {
            self.view.makeToast("Password should have 7 to 16 characters.")
            return
        } else if self.confirmPasswordtxt.text!.isEmpty {
            self.view.makeToast("Please Confirm your Password")
            return
        } else if self.confirmPasswordtxt.text! != self.newpasswordTxt.text! {
            self.view.makeToast("Passwords not matched.")
            return
        }
        
        self.changePasswordAPI()
    }

    func changePasswordAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
        let param:[String:Any] = [ "oldPassword": self.oldPasswordTxt.text!, "newPassword": self.newpasswordTxt.text!]
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_CHANGE_PASSWORD, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    
                    self.view.makeToast(json["message"].stringValue)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.navigationController?.popViewController(animated: true)
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
