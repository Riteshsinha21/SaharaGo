//
//  ProfileVC.swift
//  SaharaGo
//
//  Created by Ritesh on 08/12/20.
//

import UIKit
import SQLite

class ProfileVC: SuperViewController {

    @IBOutlet var userCoverImg: UIImageView!
    @IBOutlet var userProfileImg: UIImageView!
    @IBOutlet var logOutBtn: UIButton!
    @IBOutlet var loginView: UIView!
    
    var database : Connection!
    
    var currentOrderArr = [current_order_Address_main_struct]()
    var cartDataArr = [current_order_cartData_struct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
//            self.logOutBtn.isHidden = false
//        } else {
//            self.logOutBtn.isHidden = true
//        }
        isProfileTab = "no"
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
        guard let countryColorStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.COUNTRY_COLOR_CODE) as? String else {return}
        guard let rgba = countryColorStr.slice(from: "(", to: ")") else { return }
        let myStringArr = rgba.components(separatedBy: ",")
        self.logOutBtn.backgroundColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        
        
        
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) == nil {
            self.loginView.isHidden = false
        } else {
            self.loginView.isHidden = true
            self.getProfileDetail()
        }
    }
    
    func getProfileDetail() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_DETAIL_BY_TOKEN, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    let firstName = json["metaData"]["firstName"].stringValue
                    let lastName = json["metaData"]["lastName"].stringValue
                    let userImage = json["metaData"]["image"].stringValue
                    let coverImage = json["metaData"]["coverImage"].stringValue
                    let emailMobile = json["emailMobile"].stringValue
                    let country = json["country"].stringValue
                    
                    self.setData(profileDetail_Struct.init(firstName: firstName, lastName: lastName, emailMobile: emailMobile, country: country, userImage: userImage, coverImage: coverImage))
                    
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
    
    func setData(_ profileInfo: profileDetail_Struct) {
        
        self.userProfileImg.contentMode = .scaleToFill
        self.userProfileImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(profileInfo.userImage)"), placeholderImage: UIImage(named: "profile-1"))
        self.userCoverImg.contentMode = .scaleToFill
        self.userCoverImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(profileInfo.coverImage)"), placeholderImage: UIImage(named: "cover-1"))
    }
    
    @IBAction func ordersAction(_ sender: Any) {
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func helpCenterAction(_ sender: Any) {
    }
    
    @IBAction func wishlistAction(_ sender: Any) {
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func profileDetailsAction(_ sender: Any) {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = userStoryboard.instantiateViewController(withIdentifier: "ProfileDetailVC") as! ProfileDetailVC
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("You are not signed in yet.")
        }
        
    }
    
    @IBAction func addressAction(_ sender: Any) {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = userStoryboard.instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast("You are not signed in yet.")
        }
    }
    
    @IBAction func languageAction(_ sender: Any) {
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            self.logOutAPICall()
        } else {
            self.view.makeToast("Successfully Looged Out.")
            
            if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
                self.deleteLocalProducts()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = userStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
                UIApplication.shared.delegate!.window!!.rootViewController = viewController
            }
        }
        
    }
    

    
    func deleteLocalProducts() {
        do {
            let users = Table("products")
            try self.database.run(users.delete())
            //try self.database.run(deleteNote)
            //self.getTodayNotes()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    func logOutAPICall() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
                        
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_LOGOUT, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                                        
                    UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
                    UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)
                    UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.CART_ID)
                    UserDefaults.standard.set(0, forKey: "cartCount")
                    isLogin = "no"
                    isSignUp = "no"
                    self.view.makeToast("Successfully Looged Out.")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = userStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
                        UIApplication.shared.delegate!.window!!.rootViewController = viewController
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
    
    @IBAction func loginAction(_ sender: Any) {
        isProfileTab = "yes"
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    

}
