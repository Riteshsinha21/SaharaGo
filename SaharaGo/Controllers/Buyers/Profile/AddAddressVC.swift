//
//  AddAddressVC.swift
//  SaharaGo
//
//  Created by Ritesh on 08/12/20.
//

import UIKit
import DLRadioButton

class AddAddressVC: UIViewController, UIPickerViewDelegate {
    
    var finalItemDic: NSMutableDictionary = NSMutableDictionary()
    
    @IBOutlet var countryTxt: UITextField!
    @IBOutlet var zipcodeTxt: UITextField!
    @IBOutlet var stateTxt: UITextField!
    @IBOutlet var cityTxt: UITextField!
    @IBOutlet var landmarkTxt: UITextField!
    @IBOutlet var addressTxt: UITextField!
    @IBOutlet var mobileTxt: UITextField!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var firstNameTxt: UITextField!
    @IBOutlet var homeRadioBtn: DLRadioButton!
    @IBOutlet var workRadioBtn: DLRadioButton!
    
    var addressInfo = address_Struct()
    var CountryList = [Country_List_Struct]()
    var picker = UIPickerView()
    var paramsDic:NSMutableDictionary = NSMutableDictionary()
    var addressType = ""
    
    struct Country_List_Struct {
        var countryName:String = ""
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
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        self.firstNameTxt.text = self.addressInfo.firstName
        self.lastNameTxt.text = self.addressInfo.lastName
        self.mobileTxt.text = self.addressInfo.phone
        self.addressTxt.text = self.addressInfo.streetAddress
        self.landmarkTxt.text = self.addressInfo.landmark
        self.cityTxt.text = self.addressInfo.city
        self.stateTxt.text = self.addressInfo.state
        self.zipcodeTxt.text = self.addressInfo.zipcode
        self.countryTxt.text = self.addressInfo.country
        if self.addressInfo.addressType == "Home" {
            self.homeRadioBtn.isSelected = true
        } else if self.addressInfo.addressType == "Work" {
            self.workRadioBtn.isSelected = true
        }
        
    }
    
    @IBAction func onSelectRadioBtn(_ sender: DLRadioButton) {
        let title = sender.titleLabel!.text!
    
        if title == "Home"{
            self.addressType = "Home"
        } else {
            self.addressType = "Work"
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        if self.addressInfo.firstName == "" {
            print("save")
            if self.firstNameTxt.text!.isEmpty {
                self.view.makeToast("Please enter First Name.")
                return
            } else if self.lastNameTxt.text!.isEmpty {
                self.view.makeToast("Please enter Last Name.")
                return
            } else if self.mobileTxt.text!.isEmpty {
                self.view.makeToast("Please enter Mobile.")
                return
            } else if !self.mobileTxt.text!.contains("+") {
                self.view.makeToast("Please Enter your Phone Code.")
                return
            } else if self.addressTxt.text!.isEmpty {
                self.view.makeToast("Please enter Street Address.")
                return
            } else if self.landmarkTxt.text!.isEmpty {
                self.view.makeToast("Please enter Landmark.")
                return
            } else if self.cityTxt.text!.isEmpty {
                self.view.makeToast("Please enter City.")
                return
            } else if self.stateTxt.text!.isEmpty {
                self.view.makeToast("Please enter State.")
                return
            } else if self.zipcodeTxt.text!.isEmpty {
                self.view.makeToast("Please enter Zipcode.")
                return
            } else if self.countryTxt.text!.isEmpty {
                self.view.makeToast("Please enter Country.")
                return
            } else if self.addressType == "" {
                self.view.makeToast("Please select Address Type.")
                return
            }

            self.finalItemDic.setValue(self.firstNameTxt.text!, forKey: "firstName")
            self.finalItemDic.setValue(self.lastNameTxt.text!, forKey: "lastName")
            self.finalItemDic.setValue(self.mobileTxt.text!, forKey: "phone")
            self.finalItemDic.setValue(self.addressTxt.text!, forKey: "streetAddress")
            self.finalItemDic.setValue(self.countryTxt.text!, forKey: "country")
            self.finalItemDic.setValue(self.stateTxt.text!, forKey: "state")
            self.finalItemDic.setValue(self.cityTxt.text!, forKey: "city")
            self.finalItemDic.setValue(self.zipcodeTxt.text!, forKey: "zipcode")
            self.finalItemDic.setValue(self.landmarkTxt.text!, forKey: "landmark")
            self.finalItemDic.setValue(self.addressType, forKey: "addressType")

            self.addAddressAPI()
        } else {
            self.updateAddressAPI()
        }
        
    }
    
    @IBAction func markDefaultAction(_ sender: Any) {
        if self.addressInfo.id == "" {
            self.view.makeToast("Please save the address before marking this as default.")
        } else {
            self.defaultAddressAPI()
        }
    }
    
    func addAddressAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "metaData": self.finalItemDic]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_ADD_ADDRESS, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    self.view.makeToast("Address saved Successfully.")
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
    
    func updateAddressAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            self.paramsDic.setValue(self.firstNameTxt.text!, forKey: "firstName")
            self.paramsDic.setValue(self.lastNameTxt.text!, forKey: "lastName")
            self.paramsDic.setValue(self.mobileTxt.text!, forKey: "phone")
            self.paramsDic.setValue(self.addressTxt.text!, forKey: "streetAddress")
            self.paramsDic.setValue(self.countryTxt.text!, forKey: "country")
            self.paramsDic.setValue(self.stateTxt.text!, forKey: "state")
            self.paramsDic.setValue(self.cityTxt.text!, forKey: "city")
            self.paramsDic.setValue(self.zipcodeTxt.text!, forKey: "zipcode")
            self.paramsDic.setValue(self.landmarkTxt.text!, forKey: "landmark")
            self.paramsDic.setValue(self.addressType, forKey: "addressType")
            
            let param:[String:Any] = [ "metaData": self.paramsDic]
            
            var apiUrl = BASE_URL + PROJECT_URL.USER_UPDATE_ADDRESS
            apiUrl = apiUrl + "\(self.addressInfo.id)"
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
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
    
    func defaultAddressAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [:]
            
            var apiUrl = BASE_URL + PROJECT_URL.USER_MARK_DEFAULT_ADDRESS
            apiUrl = apiUrl + "\(self.addressInfo.id)"
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
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
    
    func getCountryList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_COUNTY_LIST_COLOR_CODE, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    for i in 0..<json["countryColorCodeList"].count
                    {
                        let countryName =  json["countryColorCodeList"][i]["countryName"].stringValue
                        self.CountryList.append(Country_List_Struct.init(countryName: countryName))
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

extension AddAddressVC : UIDocumentPickerDelegate, UIPickerViewDataSource {
    
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
        //self.isdCode = countryDic.value(forKey: "isdCode") as! String
    }
}
