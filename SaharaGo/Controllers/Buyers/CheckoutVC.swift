//
//  CheckoutVC.swift
//  SaharaGo
//
//  Created by Ritesh on 30/12/20.
//

import UIKit
import Braintree
import BraintreeDropIn

class CheckoutVC: UIViewController {
    
    @IBOutlet var orderConfirmView: UIView!
    @IBOutlet var selectAddressView: UIView!
    @IBOutlet var deliveryAddressView: UIView!
    @IBOutlet var toalAmountLbl: UILabel!
    @IBOutlet var addressLbl: UILabel!
    @IBOutlet var addressSubLbl: UILabel!
    @IBOutlet var selectAddressBtn: UIButton!
    
    var totalAmount : Double = Double()
    var defaultAddressArr = [address_Struct]()
    var cartMetaDataDic: NSMutableDictionary = NSMutableDictionary()
    var orderMetaDataDic: NSMutableDictionary = NSMutableDictionary()
    var itemsArr: NSMutableArray = NSMutableArray()
    var cartInfo = cartProductListStruct()
    
    var clientToken = String()
    var orderId = String()
    var braintreeClient: BTAPIClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.defaultAddressArr.count == 0 {
            self.getAddressAPI()
        }
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        self.cartInfo = cartProducts[0]
        self.toalAmountLbl.text = "Total Amount: \(cartInfo.currency) \(self.totalAmount)"
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.CART_ID) != nil {
            // self.getCartDetailOfUser()
        }
    }
    
    @IBAction func selectAddressAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "AddressVC") as! AddressVC
        
        vc.completionHandlerCallback = {(attributesDic: address_Struct!)->Void in
            self.defaultAddressArr.removeAll()
            
            self.orderMetaDataDic.setValue(attributesDic.id, forKey: "billingAddressId")
            self.orderMetaDataDic.setValue(attributesDic.id, forKey: "shippingAddressId")
            
            self.defaultAddressArr.append(address_Struct.init(id: attributesDic.id, firstName: attributesDic.firstName, lastName: attributesDic.lastName, phone: attributesDic.phone, streetAddress: attributesDic.streetAddress, country: attributesDic.country, state: attributesDic.state, city: attributesDic.city, zipcode: attributesDic.zipcode, landmark: attributesDic.landmark, isDefault: attributesDic.isDefault))
            
            if self.defaultAddressArr.count > 0 {
                self.deliveryAddressView.isHidden = false
                self.selectAddressView.isHidden = true
                self.selectAddressBtn.isHidden = false
                
                DispatchQueue.main.async {
                    let info = self.defaultAddressArr[0]
                    self.addressLbl.text = "\(info.firstName) \(info.lastName)"
                    self.addressSubLbl.text = "\(info.streetAddress) \(info.city) \(info.country)\nMobile:\(info.phone)"
                }
                
            } else {
                self.deliveryAddressView.isHidden = true
                self.selectAddressView.isHidden = false
                self.selectAddressBtn.isHidden = true
            }
            
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func paynowAction(_ sender: Any) {
        
        print(cartProducts)
        self.itemsArr.removeAllObjects()
        for items in cartProducts {
            
            var itemDic: NSMutableDictionary = NSMutableDictionary()
            var metaDataDic: NSMutableDictionary = NSMutableDictionary()
            itemDic.setValue(items.productId, forKey: "productId")
            itemDic.setValue(items.itemId, forKey: "itemId")
            itemDic.setValue(items.quantity, forKey: "quantity")
            
            itemDic.setValue(items.name, forKey: "name")
            //itemDic.setValue("", forKey: "category")
            itemDic.setValue(items.stock, forKey: "stock")
            itemDic.setValue(items.currency, forKey: "currency")
            itemDic.setValue(items.price, forKey: "price")
            itemDic.setValue(items.discountPercent, forKey: "discountPercent")
            itemDic.setValue(items.discountedPrice, forKey: "discountedPrice")
            let total = (items.quantity as NSString).doubleValue * (items.discountedPrice as NSString).doubleValue
            itemDic.setValue(total, forKey: "totalPrice")
            metaDataDic.setValue(items.description, forKey: "description")
            metaDataDic.setValue([items.images], forKey: "images")
            itemDic.setValue(metaDataDic, forKey: "metaData")
            self.itemsArr.add(itemDic)
        }
        self.cartMetaDataDic.setValue(self.itemsArr, forKey: "items")
        if self.orderMetaDataDic.value(forKey: "billingAddressId") != nil {
            self.orderProcessApi()
        } else {
            self.view.makeToast("Please add Delivery Address.")
        }
    }
    
    func orderProcessApi() {
        
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            //            let param:[String:Any] = [ "cartId": UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.CART_ID)!,"cartMetaData":self.cartMetaDataDic,"totalPrice": " \(self.cartInfo.currency) \(self.totalAmount)", "orderMetaData": self.orderMetaDataDic]
            
            let param:[String:Any] = [ "cartId": UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.CART_ID)!,"cartMetaData":self.cartMetaDataDic,"totalPrice": "\(self.totalAmount)", "orderMetaData": self.orderMetaDataDic]
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_ORDER_PROCESS, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    
                    self.orderId = json["orderId"].stringValue
                    self.clientToken = json["brainTreeToken"].stringValue
                    self.braintreeClient = BTAPIClient(authorization: self.clientToken)
                    
                    self.showDropIn(clientTokenOrTokenizationKey: self.clientToken)
                    
                    //save data in userdefault..
                    self.view.makeToast(json["message"].stringValue)
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    //                        self.dismiss(animated: true, completion: nil)
                    //                    }
                    
                    
                }
                else {
                    self.view.makeToast("\(json["message"].stringValue)")
                    // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.applePayDisabled = false // Make sure that  applePayDisabled is false
        
        let dropIn = BTDropInController.init(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                controller.dismiss(animated: true, completion: nil)
                print("CANCELLED")
                
            } else if let result = result{
                
                switch result.paymentOptionType {
                case .applePay ,.payPal,.masterCard,.discover,.visa:
                    // Here Result success  check paymentMethod not nil if nil then user select applePay
                    if let paymentMethod = result.paymentMethod{
                        //paymentMethod.nonce  You can use  nonce now
                        
                        let nonce = result.paymentMethod!.nonce
                        print( nonce)
                        //self.postNonceToServer(paymentMethodNonce: nonce, deviceData : self.deviceData)
                        self.autheticatePayment(paymentMethodNonce: nonce)
                        controller.dismiss(animated: true, completion: nil)
                    }else{
                        
                        controller.dismiss(animated: true, completion: {
                            
                            self.braintreeClient = BTAPIClient(authorization: clientTokenOrTokenizationKey)
                            
                            // call apple pay
                            let paymentRequest = self.paymentRequest()
                            
                            // Example: Promote PKPaymentAuthorizationViewController to optional so that we can verify
                            // that our paymentRequest is valid. Otherwise, an invalid paymentRequest would crash our app.
                            
                            if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                                as PKPaymentAuthorizationViewController?
                            {
                                vc.delegate = self
                                self.present(vc, animated: true, completion: nil)
                            } else {
                                print("Error: Payment request is invalid.")
                            }
                            
                        })
                        
                    }
                default:
                    print("error")
                    controller.dismiss(animated: true, completion: nil)
                }
                
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            
            
        }
        
        self.present(dropIn!, animated: true, completion: nil)
        
    }
    
    func autheticatePayment(paymentMethodNonce: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "orderId": self.orderId,"amount": "\(self.totalAmount)", "nonceFromTheClient": paymentMethodNonce]
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_AUTHENTICATE_PAYMENT, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    
                    self.view.makeToast("Order Placed Successfully.")
                    
                    self.orderConfirmView.isHidden = false
                    
                    UserDefaults.standard.set(0, forKey: "cartCount")
                    let cartCount = ["userInfo": ["cartCount": 0]]
                    NotificationCenter.default
                        .post(name:           NSNotification.Name("updateCartBadge"),
                              object: nil,
                              userInfo: cartCount)
                    
                }
                else {
                    self.view.makeToast("\(json["message"].stringValue)")
                    // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
    
    @IBAction func orderConfirmDoneAction(_ sender: Any) {
        self.navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
            if vc.isKind(of: HomeNewVC.self) || vc.isKind(of: ProductsVC.self) || vc.isKind(of: ProductDetailsVC.self) || vc.isKind(of: CartNewVC.self) || vc.isKind(of: CategoriesVC.self) || vc.isKind(of: WishlistVC.self) || vc.isKind(of: AllProductsVC.self) {
                return true
            } else {
                return false
            }
        })
        
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editAddressAction(_ sender: Any) {
        
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
        vc.modalPresentationStyle = .fullScreen
        
        vc.addressInfo = self.defaultAddressArr[0]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func getAddressAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_ADDRESSES, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    self.defaultAddressArr.removeAll()
                    for i in 0..<json["addressList"].count {
                        let firstName =  json["addressList"][i]["metaData"]["firstName"].stringValue
                        let lastName =  json["addressList"][i]["metaData"]["lastName"].stringValue
                        let phone =  json["addressList"][i]["metaData"]["phone"].stringValue
                        let streetAddress =  json["addressList"][i]["metaData"]["streetAddress"].stringValue
                        let landmark =  json["addressList"][i]["metaData"]["landmark"].stringValue
                        let city =  json["addressList"][i]["metaData"]["city"].stringValue
                        let state =  json["addressList"][i]["metaData"]["state"].stringValue
                        let zipcode =  json["addressList"][i]["metaData"]["zipcode"].stringValue
                        let country =  json["addressList"][i]["metaData"]["country"].stringValue
                        let isDefault =  json["addressList"][i]["isDefault"].boolValue
                        let id =  json["addressList"][i]["id"].stringValue
                        
                        if isDefault {
                            
                            self.orderMetaDataDic.setValue(id, forKey: "billingAddressId")
                            self.orderMetaDataDic.setValue(id, forKey: "shippingAddressId")
                            
                            self.defaultAddressArr.append(address_Struct.init(id: id, firstName: firstName, lastName: lastName, phone: phone, streetAddress: streetAddress, country: country, state: state, city: city, zipcode: zipcode, landmark: landmark, isDefault: isDefault))
                        }
                        
                        
                    }
                    
                    if self.defaultAddressArr.count > 0 {
                        self.deliveryAddressView.isHidden = false
                        self.selectAddressView.isHidden = true
                        self.selectAddressBtn.isHidden = false
                        
                        DispatchQueue.main.async {
                            let info = self.defaultAddressArr[0]
                            self.addressLbl.text = "\(info.firstName) \(info.lastName)"
                            self.addressSubLbl.text = "\(info.streetAddress) \(info.city) \(info.country)\nMobile:\(info.phone)"
                        }
                        
                    } else {
                        self.deliveryAddressView.isHidden = true
                        self.selectAddressView.isHidden = false
                        self.selectAddressBtn.isHidden = true
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
    
}

extension CheckoutVC : PKPaymentAuthorizationViewControllerDelegate{
    
    func paymentRequest() -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        //paymentRequest.merchantIdentifier = "merchant.wuber1";
        paymentRequest.merchantIdentifier = "82hhc7nm5hry98kz";
        paymentRequest.supportedNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.visa, PKPaymentNetwork.masterCard];
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS;
        paymentRequest.countryCode = "US"; // e.g. US
        paymentRequest.currencyCode = "USD"; // e.g. USD
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Merchant", amount: 1.0),
            
        ]
        return paymentRequest
    }
    
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Swift.Void){
        
        // Example: Tokenize the Apple Pay payment
        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        applePayClient.tokenizeApplePay(payment) {
            (tokenizedApplePayPayment, error) in
            guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
                // Tokenization failed. Check `error` for the cause of the failure.
                
                // Indicate failure via completion callback.
                completion(PKPaymentAuthorizationStatus.failure)
                
                return
            }
            
            // Received a tokenized Apple Pay payment from Braintree.
            // If applicable, address information is accessible in `payment`.
            
            // Send the nonce to your server for processing.
            print("nonce = \(tokenizedApplePayPayment.nonce)")
            
            //self.postNonceToServer(paymentMethodNonce: tokenizedApplePayPayment.nonce, deviceData: self.deviceData)
            self.autheticatePayment(paymentMethodNonce: tokenizedApplePayPayment.nonce)
            // Then indicate success or failure via the completion callback, e.g.
            completion(PKPaymentAuthorizationStatus.success)
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
