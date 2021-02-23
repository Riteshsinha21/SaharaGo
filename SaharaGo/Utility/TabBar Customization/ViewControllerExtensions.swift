//
//  ViewControllerExtensions.swift
//  LLRTS
//
//  Created by Ritesh on 08/09/20.
//

import Foundation
import UIKit
//import SVProgressHUD

var customView = UIView()
var requiredScreen: UIViewController = UIViewController()


extension UIViewController: UITabBarControllerDelegate {
    
    func loadTabBar() -> UITabBarController {
        
        let tabBarController = UITabBarController()
        tabBarController.delegate = self
        let tabViewController1 = SellerOrdersVC(
            nibName: "SellerOrdersVC",
            bundle: nil)
        let tabViewController2 = SellerEarningsVC(
            nibName:"SellerEarningsVC",
            bundle: nil)
        let tabViewController3 = SellerProductsVC(
            nibName:"SellerProductsVC",
            bundle: nil)
        let tabViewController4 = SellerProductsVC(
            nibName:"SellerProductsVC",
            bundle: nil)
        
        let controllers = [tabViewController1, tabViewController2, tabViewController3, tabViewController4]
        tabBarController.viewControllers = controllers
        
        tabViewController1.tabBarItem = UITabBarItem(
            title: "Orders",
            image: UIImage(named: "order"),
            tag: 1)
        tabViewController2.tabBarItem = UITabBarItem(
            title: "Earnings",
            image:UIImage(named: "earnings") ,
            tag:2)
        tabViewController3.tabBarItem = UITabBarItem(
            title: "Products",
            image:UIImage(named: "product") ,
            tag:3)
        tabViewController4.tabBarItem = UITabBarItem(
            title: "More",
            image:UIImage(named: "more") ,
            tag:4)
        
        if UIDevice.current.screenType == .iPhone_XR_11 {
            customView = UIView(frame: CGRect(x: (self.view.bounds.size.width) - 80, y: (self.view.bounds.size.height) - 80, width: 44, height: 44))
        } else if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            customView = UIView(frame: CGRect(x: (self.view.bounds.size.width) - 100, y: (self.view.bounds.size.height) - 50, width: 200, height: 60))
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            customView = UIView(frame: CGRect(x: (self.view.bounds.size.width) - 100, y: (self.view.bounds.size.height) - 50, width: 200, height: 60))
        } else if UIDevice.current.screenType == .iPhones_X_XS {
            customView = UIView(frame: CGRect(x: (self.view.bounds.size.width) - 100, y: (self.view.bounds.size.height) - 80, width: 200, height: 60))
        } else {
            customView = UIView(frame: CGRect(x: (self.view.bounds.size.width) - 100, y: (self.view.bounds.size.height) - 80, width: 200, height: 60))
        }
        
        
        customView.backgroundColor = UIColor.clear
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        customView.addGestureRecognizer(gesture)
        
        tabBarController.view.addSubview(customView)
        
        
        
        //self.view.addSubview(customView)
        
        return tabBarController
        
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        
        requiredScreen = UIApplication.topViewController()!
        UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        // Do what you want
        
        let controller = ArrayChoiceTableViewController(Direction.allValues) { (direction) in
            if direction == "Manage Categories" {
                DispatchQueue.main.async {
                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellermanageCategoriesVC") as! SellermanageCategoriesVC
                    vc.modalPresentationStyle = .fullScreen
                    requiredScreen.present(vc, animated: true)
                }
                
            } else if direction == "Profile" {
                
                DispatchQueue.main.async {
                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerProfileVC") as! SellerProfileVC
                    vc.modalPresentationStyle = .fullScreen
                    requiredScreen.present(vc, animated: true)
                }
                
            } else if direction == "Change Password" {
                
                DispatchQueue.main.async {
                    let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                    let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerChangePasswordVC") as! SellerChangePasswordVC
                    vc.modalPresentationStyle = .fullScreen
                    requiredScreen.present(vc, animated: true)
                }
                
            } else if direction == "Update Location" {
                
                //                DispatchQueue.main.async {
                //                    let vc = ContactUs()
                //                    vc.modalPresentationStyle = .fullScreen
                //                    requiredScreen.present(vc, animated: true)
                //                    // requiredScreen.present(ContactUs(), animated: true, completion: nil)
                //                }
                
            } else if direction == "Log Out" {
                
                self.logOutAPI()
            }
            
        }
        controller.preferredContentSize = CGSize(width: 220, height: 190)
        
        showPopup(controller, sourceView: customView)
    }
    
    func logOutAPI() {
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
        UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)
        
        //self.view.makeToast("Successfully Looged Out.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = userStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
            UIApplication.shared.delegate!.window!!.rootViewController = viewController
        }
        
        
        
        
        
//        if Reachability.isConnectedToNetwork() {
//            showProgressOnView(appDelegateInstance.window!)
//
//            let param:[String:String] = [:]
//
//            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_LOGOUT, successBlock: { (json) in
//                print(json)
//                hideAllProgressOnView(appDelegateInstance.window!)
//                let success = json["success"].stringValue
//
//                if success == "true"
//                {
//
//                    UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN)
//                    UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_OTP_ID)
//
//                    //self.view.makeToast("Successfully Looged Out.")
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                        let viewController = userStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
//                        UIApplication.shared.delegate!.window!!.rootViewController = viewController
//                    }
//
//                }
//                else {
//                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
//                }
//            }, errorBlock: { (NSError) in
//                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
//                hideAllProgressOnView(appDelegateInstance.window!)
//            })
//
//        }else{
//            hideAllProgressOnView(appDelegateInstance.window!)
//            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
//        }
    }
    
    func validate(YourEMailAddress: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: YourEMailAddress)
    }
    

    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    public func showAlertWithDistructiveButton(_ sessionId: String) {
        let alert = UIAlertController(title: "Session Booked.", message: "Please wait for Tutor to accept your Session Request.", preferredStyle: UIAlertController.Style.alert)
        
        //        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
        //            //Cancel Action
        //        }))
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        //Sign out action
                                        
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}

extension UIDevice {
    var iPhoneX: Bool { UIScreen.main.nativeBounds.height == 2436 }
    var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var iPad: Bool { UIDevice().userInterfaceIdiom == .pad }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR_11 = "iPhone XR or iPhone 11"
        case iPhone_XSMax_ProMax = "iPhone XS Max or iPhone Pro Max"
        case iPhone_11Pro = "iPhone 11 Pro"
        case unknown
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR_11
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2426:
            return .iPhone_11Pro
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax_ProMax
        default:
            return .unknown
        }
    }
    
}

extension Date {
    func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
        let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}
