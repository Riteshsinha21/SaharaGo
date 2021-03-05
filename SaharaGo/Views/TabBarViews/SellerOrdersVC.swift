//
//  SellerOrdersVC.swift
//  SaharaGo
//
//  Created by Ritesh on 15/12/20.
//

import UIKit

enum Direction : String {
    
    case Manage_Categories = "Manage Categories"
    case Profile = "Profile"
    case Change_Password = "Change Password"
   // case Update_Location = "Update Location"
    case LogOut = "Log Out"
    
    static var allValues = [Direction.Manage_Categories.rawValue,Profile.rawValue,Change_Password.rawValue, LogOut.rawValue]
}

class SellerOrdersVC: UIViewController, UIPickerViewDelegate {
    
    let statusArr = ["Current", "Delivered", "Cancelled"]
    let orderStatusArr = ["Confirmed", "Packed", "Shipped", "Delivered"]
    
    @IBOutlet var emptySortBtn: UIButton!
    @IBOutlet var sortBtn: UIButton!
    @IBOutlet var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentOrderArr = [current_order_Address_main_struct]()
    var cartDataArr = [current_order_cartData_struct]()
    var orderId = ""
    var orderStatus = "Confirmed"
    var orderTitleStatus = "Current"
    var SortByString = ""
  
    var picker = UIPickerView()
    var toolBar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        
        self.getCurrentOrders()
        
        collectionView.register(UINib(nibName: "SellerStatusCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SellerStatusCollectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.register(UINib(nibName: "SellerOrdersCell", bundle: nil), forCellReuseIdentifier: "SellerOrdersCell")
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //self.getVendorDetailByToken()
        
    }
    
    @IBAction func notificationAction(_ sender: Any) {
            
            
    //        let indexPath: IndexPath? = tableView.indexPathForRow(at: (sender as AnyObject).convert(CGPoint.zero, to: tableView))
    //        let catinfo = self.categoriesList[indexPath!.row]
            isSubcategory = "no"
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerNotificationVC") as! SellerNotificationVC
            
    //        categoryId = "0"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    
    @IBAction func sortbtnAction(_ sender: Any) {
        self.openActionsheet()
    }
    
    private func openActionsheet() {
        let alert = UIAlertController(title: "Sort By", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "New", style: .default , handler:{ (UIAlertAction)in
            self.SortByString = "New"
            self.getFilteredOrder("Payment_Completed")
        }))
        
        alert.addAction(UIAlertAction(title: "Confirmed", style: .default , handler:{ (UIAlertAction)in
            self.SortByString = "Confirmed"
            self.getFilteredOrder("Confirmed")
        }))
        
        alert.addAction(UIAlertAction(title: "Packed", style: .default , handler:{ (UIAlertAction)in
            self.SortByString = "Packed"
            self.getFilteredOrder("Packed")
        }))
        
        alert.addAction(UIAlertAction(title: "Shipped", style: .default , handler:{ (UIAlertAction)in
            self.SortByString = "Shipped"
            self.getFilteredOrder("Shipped")
        }))
        
        alert.addAction(UIAlertAction(title: "Remove Filter", style: .default, handler:{ (UIAlertAction)in
            self.SortByString = "Remove Filter"
            self.getCurrentOrders()
        }))
        
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func getVendorDetailByToken() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_DETAIL_BY_TOKEN, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success != "true"
                {
                    
                    UserDefaults.standard.set(json["country"].stringValue, forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY)
                    
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
    
    func getCurrentOrders() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_GET_CURRENT_ORDER, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    
                    self.currentOrderArr.removeAll()
                    
                    self.cartDataArr.removeAll()
                    for i in 0..<json["orderList"].count {
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
                        
                        for j in 0..<json["orderList"][i]["cartMetaData"]["items"].count {
                            
                            let productId = json["orderList"][i]["cartMetaData"]["items"][j]["productId"].stringValue
                            let discountPercent = json["orderList"][i]["cartMetaData"]["items"][j]["discountPercent"].stringValue
                            let totalPrice = json["orderList"][i]["cartMetaData"]["items"][j]["totalPrice"].stringValue
                            let quantity = json["orderList"][i]["cartMetaData"]["items"][j]["quantity"].stringValue
                            let discountedPrice = json["orderList"][i]["cartMetaData"]["items"][j]["discountedPrice"].stringValue
                            let itemId = json["orderList"][i]["cartMetaData"]["items"][j]["itemId"].stringValue
                            let price = json["orderList"][i]["cartMetaData"]["items"][j]["price"].stringValue
                            let stock = json["orderList"][i]["cartMetaData"]["items"][j]["stock"].stringValue
                            let currency = json["orderList"][i]["cartMetaData"]["items"][j]["currency"].stringValue
                            let name = json["orderList"][i]["cartMetaData"]["items"][j]["name"].stringValue
                            
                            let images = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["images"].arrayObject
                            let description = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["description"].stringValue
                            
                            print(self.cartDataArr)
                            self.cartDataArr.append(current_order_cartData_struct.init(itemId: itemId, productId: productId, price: price, discountedPrice: discountedPrice, name: name, currency: currency, quantity: quantity, discountPercent: discountPercent, stock: stock, totalPrice: totalPrice, metaData: current_order_metaData_struct.init(images: images!, description: description)))
                            print(self.cartDataArr)
                            
                        }
                        
                        let totalPrice = json["orderList"][i]["totalPrice"].stringValue
                        let orderId = json["orderList"][i]["orderId"].stringValue
                        let orderState = json["orderList"][i]["orderState"].stringValue
                        
                        print(self.currentOrderArr)
                        self.currentOrderArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark, cartMetaData: self.cartDataArr))
                        
                       // self.currentOrderArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, addressMetaData: current_order_Address_struct.init(country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark), cartMetaData: cartDataArr))
                        
                        print(self.currentOrderArr)
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    if self.currentOrderArr.count > 0 {
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
    
    func getDeliveredOrders() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_GET_DELIVERED_ORDER, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //var cartData = [current_order_cartData_struct]()
                    self.currentOrderArr.removeAll()
                     self.cartDataArr.removeAll()
                    for i in 0..<json["orderList"].count {
                        let orderState = json["orderList"][i]["orderState"].stringValue
                        let orderId = json["orderList"][i]["orderId"].stringValue
                        let totalPrice = json["orderList"][i]["totalPrice"].stringValue
                        
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
                            
                            
                            self.cartDataArr.append(current_order_cartData_struct.init(itemId: itemId, productId: productId, price: price, discountedPrice: discountedPrice, name: name, currency: currency, quantity: quantity, discountPercent: discountPercent, stock: stock, totalPrice: totalPrice, metaData: current_order_metaData_struct.init(images: images ?? [], description: description)))
                        }
                        
                        self.currentOrderArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark, cartMetaData: self.cartDataArr))
                    }
//                    self.currentOrderArr.removeAll()
//                    var cartDataArr = [current_order_cartData_struct]()
//                    cartDataArr.removeAll()
//                    for i in 0..<json["orderList"].count {
//                        let firstName = json["orderList"][i]["addressMetaData"]["firstName"].stringValue
//                        let lastName = json["orderList"][i]["addressMetaData"]["lastName"].stringValue
//                        let phone = json["orderList"][i]["addressMetaData"]["phone"].stringValue
//                        let streetAddress = json["orderList"][i]["addressMetaData"]["streetAddress"].stringValue
//                        let city = json["orderList"][i]["addressMetaData"]["city"].stringValue
//                        let state = json["orderList"][i]["addressMetaData"]["state"].stringValue
//                        let country = json["orderList"][i]["addressMetaData"]["country"].stringValue
//                        let zipcode = json["orderList"][i]["addressMetaData"]["zipcode"].stringValue
//                        let landmark = json["orderList"][i]["addressMetaData"]["landmark"].stringValue
//
//                        for j in 0..<json["orderList"][i]["cartMetaData"]["items"].count {
//
//                            let productId = json["orderList"][i]["cartMetaData"]["items"][j]["productId"].stringValue
//                            let discountPercent = json["orderList"][i]["cartMetaData"]["items"][j]["discountPercent"].stringValue
//                            let totalPrice = json["orderList"][i]["cartMetaData"]["items"][j]["totalPrice"].stringValue
//                            let quantity = json["orderList"][i]["cartMetaData"]["items"][j]["quantity"].stringValue
//                            let discountedPrice = json["orderList"][i]["cartMetaData"]["items"][j]["discountedPrice"].stringValue
//                            let itemId = json["orderList"][i]["cartMetaData"]["items"][j]["itemId"].stringValue
//                            let price = json["orderList"][i]["cartMetaData"]["items"][j]["price"].stringValue
//                            let stock = json["orderList"][i]["cartMetaData"]["items"][j]["stock"].stringValue
//                            let currency = json["orderList"][i]["cartMetaData"]["items"][j]["currency"].stringValue
//                            let name = json["orderList"][i]["cartMetaData"]["items"][j]["name"].stringValue
//
//                            let images = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["images"].arrayObject
//                            let description = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["description"].stringValue
//
//                            print(cartDataArr)
//                            cartDataArr.append(current_order_cartData_struct.init(itemId: itemId, productId: productId, price: price, discountedPrice: discountedPrice, name: name, currency: currency, quantity: quantity, discountPercent: discountPercent, stock: stock, totalPrice: totalPrice, metaData: current_order_metaData_struct.init(images: images!, description: description)))
//                            print(cartDataArr)
//
//                        }
//
//                        let totalPrice = json["orderList"][i]["totalPrice"].stringValue
//                        let orderId = json["orderList"][i]["orderId"].stringValue
//                        let orderState = json["orderList"][i]["orderState"].stringValue
//
//                        print(self.currentOrderArr)
//                        self.currentOrderArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark, cartMetaData: cartDataArr))
//
//                        print(self.currentOrderArr)
//
//                    }
//
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                    if self.currentOrderArr.count > 0 {
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
    
    func getInProcessOrders() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_GET_INPROGRESS_ORDER, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                   // var cartData = [current_order_cartData_struct]()
                    self.currentOrderArr.removeAll()
                    self.cartDataArr.removeAll()
                    for i in 0..<json["orderList"].count {
                        let orderState = json["orderList"][i]["orderState"].stringValue
                        let orderId = json["orderList"][i]["orderId"].stringValue
                        let totalPrice = json["orderList"][i]["totalPrice"].stringValue
                        
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
                            
                            
                            self.cartDataArr.append(current_order_cartData_struct.init(itemId: itemId, productId: productId, price: price, discountedPrice: discountedPrice, name: name, currency: currency, quantity: quantity, discountPercent: discountPercent, stock: stock, totalPrice: totalPrice, metaData: current_order_metaData_struct.init(images: images ?? [], description: description)))
                        }
                        
                        self.currentOrderArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark, cartMetaData: self.cartDataArr))
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    if self.currentOrderArr.count > 0 {
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
    
    func getFilteredOrder(_ state: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            
            var  apiUrl =  BASE_URL + PROJECT_URL.VENDOR_GET_FILTERED_CURRENT_ORDER
            apiUrl = apiUrl + "\(state)"
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    
                    self.currentOrderArr.removeAll()
                    
                    self.cartDataArr.removeAll()
                    for i in 0..<json["orderList"].count {
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
                        
                        for j in 0..<json["orderList"][i]["cartMetaData"]["items"].count {
                            
                            let productId = json["orderList"][i]["cartMetaData"]["items"][j]["productId"].stringValue
                            let discountPercent = json["orderList"][i]["cartMetaData"]["items"][j]["discountPercent"].stringValue
                            let totalPrice = json["orderList"][i]["cartMetaData"]["items"][j]["totalPrice"].stringValue
                            let quantity = json["orderList"][i]["cartMetaData"]["items"][j]["quantity"].stringValue
                            let discountedPrice = json["orderList"][i]["cartMetaData"]["items"][j]["discountedPrice"].stringValue
                            let itemId = json["orderList"][i]["cartMetaData"]["items"][j]["itemId"].stringValue
                            let price = json["orderList"][i]["cartMetaData"]["items"][j]["price"].stringValue
                            let stock = json["orderList"][i]["cartMetaData"]["items"][j]["stock"].stringValue
                            let currency = json["orderList"][i]["cartMetaData"]["items"][j]["currency"].stringValue
                            let name = json["orderList"][i]["cartMetaData"]["items"][j]["name"].stringValue
                            
                            let images = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["images"].arrayObject
                            let description = json["orderList"][i]["cartMetaData"]["items"][j]["metaData"]["description"].stringValue
                            
                            print(self.cartDataArr)
                            self.cartDataArr.append(current_order_cartData_struct.init(itemId: itemId, productId: productId, price: price, discountedPrice: discountedPrice, name: name, currency: currency, quantity: quantity, discountPercent: discountPercent, stock: stock, totalPrice: totalPrice, metaData: current_order_metaData_struct.init(images: images!, description: description)))
                            print(self.cartDataArr)
                            
                        }
                        
                        let totalPrice = json["orderList"][i]["totalPrice"].stringValue
                        let orderId = json["orderList"][i]["orderId"].stringValue
                        let orderState = json["orderList"][i]["orderState"].stringValue
                        
                        print(self.currentOrderArr)
                        self.currentOrderArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark, cartMetaData: self.cartDataArr))
                        
                       // self.currentOrderArr.append(current_order_Address_main_struct.init(orderState: orderState, totalPrice: totalPrice, orderId: orderId, addressMetaData: current_order_Address_struct.init(country: country, state: state, lastName: lastName, firstName: firstName, city: city, phone: phone, zipcode: zipcode, streetAddress: streetAddress, landmark: landmark), cartMetaData: cartDataArr))
                        
                        print(self.currentOrderArr)
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    if self.currentOrderArr.count > 0 {
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
    
    
    func changeOrderStateApi(_ state: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)

            var  apiUrl =  BASE_URL + PROJECT_URL.VENDOR_CHANGE_ORDER_STATE
            apiUrl = apiUrl + "\(orderId)/"
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            
            let param:[String:Any] = ["state": state]
                        
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    if self.orderTitleStatus == "Delivered" {
                        self.getDeliveredOrders()
                    } else if self.orderTitleStatus == "Current" {
                        self.getCurrentOrders()
                    } else if self.orderTitleStatus == "InProgress" {
                        self.getInProcessOrders()
                    }
                    
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
    
    @objc func statusbtn1(_ sender : UIButton){
        // call your segue code here
        
        let selectedInfo = currentOrderArr[sender.tag]
        let currentStatus = selectedInfo.orderState
        orderId = selectedInfo.orderId
        let title = sender.titleLabel!.text!

        if title == "Mark Confirmed" {
            self.orderStatus = "Confirmed"
        } else if title == "Mark Packed" {
            self.orderStatus = "Packed"
        } else if title == "Mark Shipped" {
            self.orderStatus = "Shipped"
        } else if title == "Mark Delivered" {
            self.orderStatus = "Delivered"
        }
        
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "PopupVC") as! PopupVC
        vc.titleStr = "Change Order State"
        vc.msgStr = "Do you want to change the status of the order from \(currentStatus) to \(self.orderStatus) ?"
        vc.completionHandlerCallback = {(decision: String!)->Void in
            
            if decision == "yes" {
                self.changeOrderStateApi(self.orderStatus)
            }
        }
        self.present(vc, animated: true)
        
    }
    
    @objc func onDoneButtonTapped() {
        self.changeOrderStateApi(self.orderStatus)
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    @objc func onCancelButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
}

extension SellerOrdersVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentOrderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let nib = UINib(nibName: "SellerOrdersCell", bundle: nil)
        let cell = nib.instantiate(withOwner: self, options: nil).last as! SellerOrdersCell
        
        let info = self.currentOrderArr[indexPath.row]
        cell.nameLabel.text = info.firstName
        
        if self.orderTitleStatus == "Delivered" {
            cell.statusBtn.isHidden = true
        } else {
            cell.statusBtn.isHidden = false
        }
        
        if info.orderState == "Payment_Completed" {
            cell.statusBtn.setTitle("Mark Confirmed", for: .normal)
//            self.orderStatus = "Confirmed"
        } else if info.orderState == "Confirmed" {
            cell.statusBtn.setTitle("Mark Packed", for: .normal)
//            self.orderStatus = "Packed"
        } else if info.orderState == "Packed" {
            cell.statusBtn.setTitle("Mark Shipped", for: .normal)
//            self.orderStatus = "Shipped"
        } else if info.orderState == "Shipped" {
            cell.statusBtn.setTitle("Mark Delivered", for: .normal)
            //self.orderStatus = "Delivered"
        } else if info.orderState == "Delivered" {
            cell.statusBtn.isHidden = true
        }
        //cell.statusBtn.setTitle(info.orderState, for: .normal)
         
        cell.titleLabel.text = info.cartMetaData[0].name
//        cell.priceLabel.text = "\(info.totalPrice)"
        cell.priceLabel.text = "\(info.cartMetaData[0].currency) \(info.cartMetaData[0].discountedPrice)"
        cell.quantityLabel.text = info.cartMetaData[0].quantity
        
        if info.cartMetaData[0].metaData.images.count > 0 {
            cell.productImageView?.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.cartMetaData[0].metaData.images[0])"), placeholderImage: UIImage(named: "edit cat_img"))
        }
        
        cell.statusBtn.tag = indexPath.row
        cell.statusBtn.addTarget(self, action: #selector(self.statusbtn1(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = CurrentOrderVC()
        vc.modalPresentationStyle = .fullScreen
        let info = self.currentOrderArr[indexPath.row]
        vc.orderDetailInfo = info
        //self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.orderTitleStatus == "Delivered" {
            return 121
        } else {
            return 145
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        headerView.backgroundColor = .clear
        let headerLabel = UILabel(frame: CGRect(x: 10, y: -5, width: headerView.frame.width - 10, height: headerView.frame.height - 10))
        headerLabel.text = "Sort By: \(self.SortByString)"

        headerLabel.font = UIFont(name: "Poppins-Medium", size: 12)
        
        if self.SortByString == "" || self.SortByString == "Remove Filter" {
            print("Sort Type should not be shown.")
        } else {
            headerView.addSubview(headerLabel)
        }
        
//        if section == 0{
//            if defaultAddressArr.count > 0{
//                headerView.addSubview(headerLabel)
//            }
//        }
//
//        if section == 1{
//            if addressArr.count > 0{
//                headerView.addSubview(headerLabel)
//            }
//        }
        
        
        
        
        return headerView

    }
    
}

extension SellerOrdersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SellerStatusCollectionCell", for: indexPath) as! SellerStatusCollectionCell
        cell.statusBtn.setTitle(statusArr[indexPath.item], for: .normal)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            self.orderTitleStatus = "Cancelled"
            self.emptyView.isHidden = false
            self.sortBtn.isHidden = true
            self.emptySortBtn.isHidden = true
            //self.getDeliveredOrders()
        } else if indexPath.row == 0 {
            self.orderTitleStatus = "Current"
            self.sortBtn.isHidden = false
            self.emptySortBtn.isHidden = false
            self.getCurrentOrders()
        } else if indexPath.row == 1 {
            self.orderTitleStatus = "Delivered"
            //self.getInProcessOrders()
            self.sortBtn.isHidden = true
            self.emptySortBtn.isHidden = true
            self.getDeliveredOrders()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 50)
    }
    
}

extension SellerOrdersVC: UIDocumentPickerDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return orderStatusArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //let countryDic = self.statusArr[row]
        return self.orderStatusArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.orderStatus = self.orderStatusArr[row]
        print(self.orderStatusArr[row])
       // self.changeOrderStateApi(self.orderStatusArr[row])
        
    }
    
}
