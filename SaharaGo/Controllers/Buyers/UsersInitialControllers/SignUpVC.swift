//
//  SignUpVC.swift
//  SaharaGo
//
//  Created by Ritesh on 04/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class SignUpVC: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet var firstNameTxt: SkyFloatingLabelTextField!
    @IBOutlet var lastNameTxt: SkyFloatingLabelTextField!
    @IBOutlet var emailIdTxt: SkyFloatingLabelTextField!
    @IBOutlet var passwordTxt: SkyFloatingLabelTextField!
    @IBOutlet var confirmPasswordTxt: SkyFloatingLabelTextField!
    @IBOutlet var countryTxt: SkyFloatingLabelTextField!
    
    var metaDataDic: NSMutableDictionary = NSMutableDictionary()
    var CountryList = [Country_List_Struct]()
    var picker = UIPickerView()
    var isdCode = ""
    
    struct Country_List_Struct {
        var countryName:String = ""
        var isdCode:String = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.getCountryList()
        self.picker.delegate = self
        self.picker.dataSource = self
        self.countryTxt.inputView = picker
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
        if self.firstNameTxt.text!.isEmpty {
            self.view.makeToast("Please Enter First Name.")
            return
        } else if self.lastNameTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Last Name.")
            return
        } else if self.emailIdTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Email.")
            return
        } else if !ValidationManager.validateEmail(email: self.emailIdTxt.text!) {
            self.view.makeToast("Please enter Valid Email.")
            return
        } else if self.countryTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Country.")
            return
        } else if self.passwordTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Password.")
            return
        } else if self.passwordTxt.text!.count < 7 || self.passwordTxt.text!.count > 16 {
            self.view.makeToast("Password should have 7 to 16 characters.")
            return
        } else if self.confirmPasswordTxt.text!.isEmpty {
            self.view.makeToast("Please Confirm your Password")
            return
        } else if self.confirmPasswordTxt.text! != self.passwordTxt.text! {
            self.view.makeToast("Passwords not matched.")
            return
        }

        metaDataDic.setValue(self.firstNameTxt.text!, forKey: "firstName")
        metaDataDic.setValue(self.lastNameTxt.text!, forKey: "lastName")
        country = self.countryTxt.text!
        
        self.signupApiCall()
    }
    
    func signupApiCall() {
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
            
            
            let param:[String:Any] = [ "emailMobile": self.emailIdTxt.text!,"password":self.passwordTxt.text!,"country":self.countryTxt.text!, "fcmKey": fcmKey,"metaData":self.metaDataDic]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_SIGNUP, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    UserDefaults.standard.setValue(json["otpId"].stringValue, forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)
                    
                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
    
    func getCountryList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.GET_ALL_COUNTRY_LIST, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    for i in 0..<json["countryList"].count
                    {
                        let countryName =  json["countryList"][i]["countryName"].stringValue
                        let isdCode = json["countryList"][i]["isdCode"].stringValue
                        self.CountryList.append(Country_List_Struct.init(countryName: countryName, isdCode: isdCode))
                    }
                    print(self.CountryList)
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

extension SignUpVC : UIDocumentPickerDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CountryList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let countryDic = self.CountryList[row]
        return countryDic.countryName
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let countryDic = self.CountryList[row]
        self.countryTxt.text = countryDic.countryName
        self.isdCode = countryDic.isdCode
    }
}
