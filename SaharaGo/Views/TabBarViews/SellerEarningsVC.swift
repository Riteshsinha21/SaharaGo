//
//  SellerEarningsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 15/12/20.
//

import UIKit

struct earning_struct {
    var transactionid = ""
    var orderId = ""
    var amount = ""
}

class SellerEarningsVC: UIViewController {

    @IBOutlet var emptyView: UIView!
    @IBOutlet var earningView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var earningsArr = [earning_struct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        tableView.register(UINib(nibName: "SellerEarningCell", bundle: nil), forCellReuseIdentifier: "SellerEarningCell")
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.getEarnings()
    }

    @IBAction func notificationAction(_ sender: UIButton) {
        
        isSubcategory = "no"
        
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerNotificationVC") as! SellerNotificationVC
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func getEarnings() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_GET_TOTAL_EARNING, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.earningsArr.removeAll()

                    for i in 0..<json["earningList"].count {
                        let transactionId = json["earningList"][i]["transactionId"].stringValue
                        let amount = json["earningList"][i]["amount"].stringValue
                        let orderId = json["earningList"][i]["orderId"].stringValue
                        
                        self.earningsArr.append(earning_struct.init(transactionid: transactionId, orderId: orderId, amount: amount))

                    }
//
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                    if self.earningsArr.count > 0 {
                        self.tableView.isHidden = false
                        self.emptyView.isHidden = true
                    } else {
                        self.tableView.isHidden = true
                        self.emptyView.isHidden = false
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

extension SellerEarningsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.earningsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nib = UINib(nibName: "SellerEarningCell", bundle: nil)
        let cell = nib.instantiate(withOwner: self, options: nil).last as! SellerEarningCell
        
        let info = self.earningsArr[indexPath.row]
        cell.cellTransactionLbl.text = info.transactionid
        cell.cellOrderIdLbl.text = info.orderId
        cell.cellPaidLbl.text = "USD \(info.amount)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        headerView.backgroundColor = .white
        
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.width - 10, height: headerView.frame.height - 10))
        headerLabel.text = "EARNING LIST:"

        headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        headerView.addSubview(headerLabel)
        
        return headerView

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
}
