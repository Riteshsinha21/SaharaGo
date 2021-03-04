//
//  NotificationsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 14/01/21.
//

import UIKit

struct Notification_List {
    var title: String = ""
    var body: String = ""
    var date: String = ""
}

class NotificationsVC: UIViewController {

    @IBOutlet var startSellingBtn: UIButton!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loginView: UIView!
    
    var notificationList = [Notification_List]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        isNotification = "no"
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) == nil {
            self.loginView.isHidden = false
        } else {
            self.loginView.isHidden = true
            self.getNotificationList()
        }
        
        guard let countryColorStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.COUNTRY_COLOR_CODE) as? String else {return}
        guard let rgba = countryColorStr.slice(from: "(", to: ")") else { return }
        let myStringArr = rgba.components(separatedBy: ",")
        self.startSellingBtn.setTitleColor(UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue)), for: .normal)
        self.startSellingBtn.borderColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        
    }
    
    @IBAction func startSellingAction(_ sender: Any) {
        UserDefaults.standard.set("Sell", forKey: "userInterest")
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let viewController = userStoryboard.instantiateViewController(withIdentifier: "SellerLoginVC") as! SellerLoginVC
        UIApplication.shared.delegate!.window!!.rootViewController = viewController
    }
    
    @IBAction func loginAction(_ sender: Any) {
        isNotification = "yes"
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getNotificationList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.GET_NOTIFICATIONS, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    for i in 0..<json["notificationList"].count
                    {
                        let title =  json["notificationList"][i]["title"].stringValue
                        let body = json["notificationList"][i]["body"].stringValue
                        let date = json["notificationList"][i]["date"].stringValue
                        
                        self.notificationList.append(Notification_List.init(title: title, body: body, date: date))
                    }
                    
                    if self.notificationList.count > 0 {
                        self.tableView.isHidden = false
                        self.emptyView.isHidden = true
                    } else {
                        self.tableView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
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

extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsCell
        
        let info =  notificationList[indexPath.row]
        cell.cellTitle.text = info.title
        cell.cellBody.text = info.body
        cell.cellDate.text = getFormattedDateStr(dateStr: info.date)
        return cell
        
    }
    
}
