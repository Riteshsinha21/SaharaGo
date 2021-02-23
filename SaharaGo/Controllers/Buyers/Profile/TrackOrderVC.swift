//
//  TrackOrderVC.swift
//  SaharaGo
//
//  Created by Ritesh on 08/01/21.
//

import UIKit

struct track_struct {
    var state: String = ""
    var updatedOn: String = ""
}

class TrackOrderVC: UIViewController {

    var orderInfo = current_order_Address_main_struct()
    var trackDetailArr = [track_struct]()
    
    @IBOutlet var qtylbl: UILabel!
    @IBOutlet var confirmedTimeLbl: UILabel!
    @IBOutlet var orderConfirmedImgView: UIImageView!
    @IBOutlet var deliveredTimeLbl: UILabel!
    @IBOutlet var shippedTimeLbl: UILabel!
    @IBOutlet var packedTimeLbl: UILabel!
    @IBOutlet var placedTimeLbl: UILabel!
    @IBOutlet var addressLbl: UILabel!
    @IBOutlet var orderDeliveredImgView: UIImageView!
    @IBOutlet var orderShippedImgView: UIImageView!
    @IBOutlet var orderPackedImgView: UIImageView!
    @IBOutlet var orderPlacedImgView: UIImageView!
    @IBOutlet var totalAmntLbl: UILabel!
    @IBOutlet var orderIdLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        trackOrderAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func trackOrderAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let apiUrl = BASE_URL + PROJECT_URL.USER_TRACK_ORDER + "\(self.orderInfo.orderId)"
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.trackDetailArr.removeAll()
                    for i in 0..<json["trackDetailList"].count {
                        let state = json["trackDetailList"][i]["state"].stringValue
                        let updatedOn = json["trackDetailList"][i]["updatedOn"].stringValue
                        
                        self.trackDetailArr.append(track_struct.init(state: state, updatedOn: updatedOn))
                    }
//
                    DispatchQueue.main.async {
                        self.setData()

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
    
    private func setData() {
        self.totalAmntLbl.text = "Amt: \(self.orderInfo.totalPrice)"
        self.orderIdLbl.text = "Order Id: \(self.orderInfo.orderId)"
        self.qtylbl.text = "Qty: \(self.orderInfo.cartMetaData[0].quantity)"
        self.addressLbl.text = "\(self.orderInfo.firstName) \(self.orderInfo.lastName)\n\(self.orderInfo.streetAddress), \(self.orderInfo.city), \(self.orderInfo.country)\nMobile: \(self.orderInfo.phone)"
        
        for items in self.trackDetailArr {
            let item = items as track_struct
            print(item.state)
            
            if item.state == "Payment_Completed" {
                self.orderPlacedImgView.image = UIImage.init(named: "trackcheck")
                self.placedTimeLbl.text = getFormattedDateStr(dateStr: item.updatedOn)
            } else if item.state == "Confirmed" {
                self.orderConfirmedImgView.image = UIImage.init(named: "trackcheck")
                self.confirmedTimeLbl.text = getFormattedDateStr(dateStr: item.updatedOn)
            } else if item.state == "Packed" {
                self.orderPackedImgView.image = UIImage.init(named: "trackcheck")
                self.packedTimeLbl.text = getFormattedDateStr(dateStr: item.updatedOn)
            } else if item.state == "Shipped" {
                self.orderShippedImgView.image = UIImage.init(named: "trackcheck")
                self.shippedTimeLbl.text = getFormattedDateStr(dateStr: item.updatedOn)
            } else if item.state == "Delivered" {
                self.orderDeliveredImgView.image = UIImage.init(named: "trackcheck")
                self.deliveredTimeLbl.text = getFormattedDateStr(dateStr: item.updatedOn)
            }
            
        }
    }

}
