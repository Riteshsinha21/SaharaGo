//
//  AppDelegate.swift
//  SaharaGo
//
//  Created by ChawTech Solutions on 02/12/20.
//

import UIKit
import IQKeyboardManagerSwift
import SQLite
import Braintree
import BraintreeDropIn
import Firebase
import FirebaseMessaging
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var database : Connection!
    let gcmMessageIDKey = "gcmMessageIDKey"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
//
       // UILabel.appearance().substituteFontName = "Poppins"; // USE YOUR FONT NAME INSTEAD
       // UITextView.appearance().substituteFontName = "Poppins"; // USE YOUR FONT NAME INSTEAD
       // UITextField.appearance().substituteFontName = "Poppins";
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        //keyboard management
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil && UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.USER_TYPE) != nil {
            if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.USER_TYPE) as! String == "USER" {
                let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = userStoryboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! TabVC
                UIApplication.shared.delegate!.window!!.rootViewController = viewController
            } else {
                self.setupTabBar()
            }
            
        } else {
            let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = userStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
            UIApplication.shared.delegate!.window!!.rootViewController = viewController
        }
        
        BTAppSwitch.setReturnURLScheme("ChawtechSolutions.SaharaGo.Payments")
        //        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        //
        //        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
        //
        //            self.setupTabBar()
        //
        //        } else {
        //
        //            let initialViewController: SellerSignUpVC = sellerStoryboard.instantiateViewController(withIdentifier: "SellerSignUpVC") as! SellerSignUpVC
        //            self.window?.rootViewController = initialViewController
        //        }
        
        // Assuming your storyboard is named "Seller"
        
        //        UITabBar.appearance().unselectedItemTintColor = UIColor.red
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }

    
}

extension AppDelegate: MessagingDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print("Firebase registration token: \(String(describing: fcmToken))")
        UserDefaults.standard.set(fcmToken, forKey: "fcm_key")
        let dataDict:[String: String] = ["token": fcmToken ]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
 
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound, .badge]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}

extension AppDelegate: UITabBarControllerDelegate {
    
    func setupTabBar() {
        
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
            customView = UIView(frame: CGRect(x: (window?.bounds.size.width)! - 80, y: (window?.bounds.size.height)! - 80, width: 44, height: 44))
        } else if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            customView = UIView(frame: CGRect(x: (window?.bounds.size.width)! - 100, y: (window?.bounds.size.height)! - 50, width: 200, height: 60))
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            customView = UIView(frame: CGRect(x: (window?.bounds.size.width)! - 100, y: (window?.bounds.size.height)! - 50, width: 200, height: 60))
        } else if UIDevice.current.screenType == .iPhones_X_XS {
            customView = UIView(frame: CGRect(x: (window?.bounds.size.width)! - 100, y: (window?.bounds.size.height)! - 80, width: 200, height: 60))
        } else {
            customView = UIView(frame: CGRect(x: (window?.bounds.size.width)! - 100, y: (window?.bounds.size.height)! - 80, width: 200, height: 60))
        }
        
        customView.backgroundColor = UIColor.clear
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        customView.addGestureRecognizer(gesture)
        // window?.addSubview(customView)
        tabBarController.view.addSubview(customView)
        // tabBarController.tabBar.tintColor = UIColor.red
        window?.rootViewController = tabBarController
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
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        
        requiredScreen = UIApplication.topViewController()!
        UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
    }
    
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("ChawtechSolutions.SaharaGo.Payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }
    
    
}

extension UILabel {
    @objc var substituteFontName : String {
        get {
            return self.font.fontName;
        }
        set {
            let fontNameToTest = self.font.fontName.lowercased();
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font.pointSize)
        }
    }
}

extension UITextView {
    @objc var substituteFontName : String {
        get {
            return self.font?.fontName ?? "";
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? "";
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
        }
    }
}

extension UITextField {
    @objc var substituteFontName : String {
        get {
            return self.font?.fontName ?? "";
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? "";
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
        }
    }
}
//var appFontName       = "Poppins" //Please put your REGULAR font name
//var appFontBoldName   = "Poppins" //Please put your BOLD font name
//var appFontItalicName = "Poppins"
//extension UIFont {
//
//
//@objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
//    return UIFont(name: appFontName, size: size)!
//}
//
//@objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
//    return UIFont(name: appFontBoldName, size: size)!
//}
//
//@objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
//    return UIFont(name: appFontItalicName, size: size)!
//}
//
//@objc convenience init(myCoder aDecoder: NSCoder) {
//    if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
//        if let fontAttribute = fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")] as? String {
//            var fontName = ""
//            switch fontAttribute {
//            case "CTFontRegularUsage":
//                fontName = appFontName
//            case "CTFontEmphasizedUsage", "CTFontBoldUsage":
//                fontName = appFontBoldName
//            case "CTFontObliqueUsage":
//                fontName = appFontItalicName
//            default:
//                fontName = appFontName
//            }
//            self.init(name: fontName, size: fontDescriptor.pointSize)!
//        }
//        else {
//            self.init(myCoder: aDecoder)
//        }
//    }
//    else {
//        self.init(myCoder: aDecoder)
//    }
//}
//
//class func overrideInitialize() {
//    if self == UIFont.self {
//        let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
//        let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
//        method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)
//
//        let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
//        let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
//        method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)
//
//        let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:)))
//        let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:)))
//        method_exchangeImplementations(italicSystemFontMethod!, myItalicSystemFontMethod!)
//
//        let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
//        let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
//        method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
//    }
//}
//}
