//
//  OrderHistoryVC.swift
//  SaharaGo
//
//  Created by Ritesh on 06/01/21.
//

import UIKit
import Cosmos

class OrderHistoryVC: SuperViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    
    var OrderHistoryArr = [current_order_Address_main_struct]()
    var cartDataArr = [current_order_cartData_struct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.getsOrderHistory()
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    @IBAction func cellCancelAction(_ sender: UIButton) {
        self.view.makeToast("In Progress")
    }
    
    @IBAction func cellTrackAction(_ sender: UIButton) {
        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
        let info = self.OrderHistoryArr[indexPath!.row]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "TrackOrderVC") as! TrackOrderVC
        vc.orderInfo = info
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ratingAction(_ sender: UIButton) {
        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
        let info = self.OrderHistoryArr[indexPath!.row]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        vc.orderInfo = info
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getsOrderHistory() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_ORDER_HISTORY, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.OrderHistoryArr.removeAll()
                    self.cartDataArr.removeAll()
                    for i in 0..<json["orderList"].count {
                        let orderState = json["orderList"][i]["orderState"].stringValue
                        let orderId = json["orderList"][i]["orderId"].stringValue
                        let totalPrice = json["orderList"][i]["totalPrice"].stringValue
                        let isRated = json["orderList"][i]["isRated"].boolValue
                        let userRating = json["orderList"][i]["rating"].doubleValue
                        let userReview = json["orderList"][i]["review"].stringValue

                        let firstName = json["orderList"][i]["addressMetaData"]["firstName"].stringValue
                        let lastName = json["orderList"][i]["addressMetaData"]["lastName"].stringValue
                        let phone = json["orderList"][i]["addressMetaData"]["phone"].stringValue
                        let streetAddress = json["orderList"][i]["addressMetaData"]["streetAddress"].stringValue
                        let city = json["orderList"][i]["addressMetaData"]["city"].stringValue
                        let state = json["orderList"][i]["addressMetaData"]["state"].stringValue
                        let country = json["orderList"][i]["addressMetaData"]["country"].stringValue
                        let zipcode = json["orderList"][i]["addressMetaData"]["zipcode"].stringValue
                        let landmark = json["orderList"][i]["addressMetaData"]["landmark"].stringValue

                        self.cartDataArr.removeAll()

                        for j in 0..<json["orderList"][i]["cartMetaData"]["items"].count{
                            let name = json["orderList"][i]["cartMetaData"]["items"][j]["name"].stringValue
                            let itemId = json["orderList"][i]["cartMetaData"]["items"][j]["itemId"].stringValue
                            let stock = json["orderList"][i]["cartMetaData"]["items"][j]["stock"].stringValue
                            let price = json["orderList"][i]["cartMetaData"]["items"][j]["price"].stringValue
                            let totalPrice = json["orderList"][i]["cartMetaData"]["items"][j]["totalPrice"].stringValue
                            let currency = json["orderList"][i]["cartMetaData"]["items"][j]["currency"].stringValue
                            let discountPercent = json["orderList"][i]["cartMetaData"]["items"][j]["discountPercent"].stringValue
                            let productId = json["orderList"][i]["cartMetaData"]["items"][j]["productId"].stringValue
                            let discountedPrice = json["orderList"][i]["cartMetaData"]["items"][j]["discountedPrice"].stringValue
                            let quantity = json["orderList"][i]["cartMetaData"]["items"][j]["quantity"].stringValue
                            let images = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["images"].arrayObject
                            let description = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["description"].stringValue
                            let rating = json["orderList"][i]["cartMetaData"]["items"][j]["rating"].doubleValue


                            self.cartDataArr.append(current_order_cartData_struct.init(itemId: itemId, productId: productId, price: price, discountedPrice: discountedPrice, name: name, currency: currency, quantity: quantity,discountPercent: discountPercent, stock: stock, totalPrice: totalPrice, isRated: isRated, metaData: current_order_metaData_struct.init(images: images ?? [], description: description), rating: rating, userRating: userRating, userReview: userReview))
                        }

                        self.OrderHistoryArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark, cartMetaData: self.cartDataArr))
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                    }

                    if self.OrderHistoryArr.count > 0 {
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

extension OrderHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
//    private func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.OrderHistoryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = self.OrderHistoryArr[indexPath.row]
        if info.orderState == "Delivered" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryRatingCell", for: indexPath) as! OrderHistoryRatingCell
            
            cell.orderIdLbl.text = "Order Id: \(info.orderId)"
            cell.cellTitleLbl.text = info.cartMetaData[0].name
            cell.cellPriceLbl.text = "\(info.cartMetaData[0].currency) \(info.cartMetaData[0].discountedPrice)"
            cell.celldesclbl.text = info.cartMetaData[0].metaData.description
            
            cell.productRatingView.rating = Double(info.cartMetaData[0].userRating)
            cell.productRatingView.settings.updateOnTouch = false
            cell.productRatingView.settings.fillMode = .precise
            
            if info.cartMetaData[0].isRated {
                cell.ratingView.isHidden = false
                cell.cellRatingBtn.setTitle("View Your Rating", for: .normal)
            } else {
                cell.ratingView.isHidden = false
                cell.cellRatingBtn.setTitle("Rate your Experience", for: .normal)
            }
            
            if info.cartMetaData[0].metaData.images.count > 0 {
                cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.cartMetaData[0].metaData.images[0])"), placeholderImage: UIImage(named: "edit cat_img"))
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
                        
            cell.orderIdLbl.text = "Order Id: \(info.orderId)"
            cell.cellTitleLbl.text = info.cartMetaData[0].name
            cell.cellPriceLbl.text = "\(info.cartMetaData[0].currency) \(info.cartMetaData[0].discountedPrice)"
            cell.celldesclbl.text = info.cartMetaData[0].metaData.description
            
            cell.ratingView.rating = Double(info.cartMetaData[0].rating)
            cell.ratingView.settings.updateOnTouch = false
            cell.ratingView.settings.fillMode = .precise
            
            
            //        if info.orderState == "Delivered" {
            //            cell.cancelView.isHidden = true
            //        } else {
            //            cell.cancelView.isHidden = false
            //        }
            
            if info.cartMetaData[0].metaData.images.count > 0 {
                cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.cartMetaData[0].metaData.images[0])"), placeholderImage: UIImage(named: "edit cat_img"))
            }
            return cell
        }
        
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let info = self.OrderHistoryArr[indexPath.row]
//        if info.orderState == "Delivered" {
//            return 164
//        } else {
//            return 199
//        }
        return 199
         
    }
    
}
