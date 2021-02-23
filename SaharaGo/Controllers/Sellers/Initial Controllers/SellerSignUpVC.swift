//
//  SellerSignUpVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit
import SkyFloatingLabelTextField

class SellerSignUpVC: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet var firstNameTxt: SkyFloatingLabelTextField!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var emailIdTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var confirmPasswordTxt: UITextField!
    @IBOutlet var countryTxt: UITextField!
    @IBOutlet var zipCodeTxt: SkyFloatingLabelTextField!
    @IBOutlet var stateTxt: SkyFloatingLabelTextField!
    @IBOutlet var cityTxt: SkyFloatingLabelTextField!
    @IBOutlet var landmarktxt: SkyFloatingLabelTextField!
    @IBOutlet var streetTxt: SkyFloatingLabelTextField!
    
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
    
    @IBAction func signupAction(_ sender: Any) {
        
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
        } else if self.streetTxt.text!.isEmpty {
            self.view.makeToast("Please Enter Address.")
            return
        } else if self.landmarktxt.text!.isEmpty {
            self.view.makeToast("Please Enter Landmark.")
            return
        } else if self.cityTxt.text!.isEmpty {
            self.view.makeToast("Please Enter City.")
            return
        } else if self.stateTxt.text!.isEmpty {
            self.view.makeToast("Please Enter State.")
            return
        } else if self.zipCodeTxt.text!.isEmpty {
            self.view.makeToast("Please Enter ZipCode.")
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
        metaDataDic.setValue(self.streetTxt.text!, forKey: "streetAddress")
        metaDataDic.setValue(self.countryTxt.text!, forKey: "country")
        country = self.countryTxt.text!
        metaDataDic.setValue(self.stateTxt.text!, forKey: "state")
        metaDataDic.setValue(self.cityTxt.text!, forKey: "city")
        metaDataDic.setValue(self.zipCodeTxt.text!, forKey: "zipcode")
        metaDataDic.setValue(self.landmarktxt.text!, forKey: "landmark")
        
        //self.signupApiCall(email: self.emailIdTxt.text!, phoneNumber: "\(self.zipCodeTxt.text!)\(self.mobileTxt.text!)", controller: self)
        
        self.signupApiCall(email: self.emailIdTxt.text!, controller: self)
        
    }
    
    @IBAction func signInAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func signupApiCall(email:String,controller:UIViewController)
    {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            if let objFcmKey = UserDefaults.standard.object(forKey: "fcm_key") as? String
            {
                fcmKey = objFcmKey
            }
            else
            {
                fcmKey = "abcdef"
            }
            
            let param:[String:Any] = [ "emailMobile": email,"password":self.passwordTxt.text!,"country":self.countryTxt.text!, "fcmKey": fcmKey,"metaData":self.metaDataDic]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_SIGNUP_API, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    UserDefaults.standard.setValue(json["otpId"].stringValue, forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)
                    
                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerSignUpOTPVC") as! SellerSignUpOTPVC
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
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

extension SellerSignUpVC : UIDocumentPickerDelegate, UIPickerViewDataSource {
    
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
