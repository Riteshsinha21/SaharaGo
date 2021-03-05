//
//  WishlistVC.swift
//  SaharaGo
//
//  Created by Ritesh on 07/12/20.
//

import UIKit

class WishlistVC: SuperViewController {
    
    @IBOutlet var startSellingBtn: UIButton!
    @IBOutlet var loginView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var cartBadgeLbl: UILabel!
    @IBOutlet weak var wishlistCollectionView: UICollectionView!
    
    var labelArr = ["cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe","cdsafc", "dacwe"]
    
    var costArr = ["12", "22","23", "34","11", "21","143", "1311","12", "22","23", "34","11", "21","143", "1311","12", "22","23", "34","11", "21","143", "1311","12", "22","23", "34","11", "21","143", "1311"]
    
    var wishListArr = [categoryProductListStruct]()
    var dbItemsArr: NSMutableArray = NSMutableArray()
    var finalItemDic: NSMutableDictionary = NSMutableDictionary()
    var productDetails = categoryProductListStruct()
    var udCartId = ""
    var testArr = [String]()
    var itemIdToRemoveFromWishlist = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge(_:)), name: Notification.Name("updateCartBadge"), object: nil)
        
        self.cartBadgeLbl.isHidden = true
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                self.cartBadgeLbl.isHidden = true
            } else {
                //self.cartBadgeLbl.isHidden = false
                self.cartBadgeLbl.text = "\(cartCount)"
            }
            
        }
        
    }
    
    @objc func updateCartBadge(_ notification: Notification) {
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                self.cartBadgeLbl.isHidden = true
            } else {
                //self.cartBadgeLbl.isHidden = false
                let cartCountDic = notification.userInfo?["userInfo"] as? [String: Any] ?? [:]
                self.cartBadgeLbl.text = "\(String(describing: cartCountDic["cartCount"]!))"
            }
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isWishlistTab = "no"
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        //self.navigationController?.navigationBar.topItem?.title = "Wishlist"
        guard let countryColorStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.COUNTRY_COLOR_CODE) as? String else {return}
        guard let rgba = countryColorStr.slice(from: "(", to: ")") else { return }
        let myStringArr = rgba.components(separatedBy: ",")
        self.tabBarController?.tabBar.tintColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        self.navigationController?.navigationBar.barTintColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.startSellingBtn.setTitleColor(UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue)), for: .normal)
        self.startSellingBtn.borderColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        
        self.makeNavCartBtn()
        
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            self.wishlistCollectionView.isHidden = false
            self.emptyView.isHidden = true
            self.loginView.isHidden = true
            self.getWishlistProductsAPI()
        } else {
            self.wishlistCollectionView.isHidden = true
            self.loginView.isHidden = false

            
        }
        
    }
    
    func makeNavCartBtn() {
        
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "bag"), style: .plain, target: self, action: #selector(cartTapped))
                
            } else {
                
                let filterBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
                filterBtn.setImage(UIImage.init(named: "bag"), for: .normal)
                filterBtn.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
                
                let lblBadge = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 15, height: 15))
                lblBadge.backgroundColor = UIColor.white
                lblBadge.clipsToBounds = true
                lblBadge.layer.cornerRadius = 7
                lblBadge.textColor = UIColor.black
                lblBadge.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                lblBadge.textAlignment = .center
                lblBadge.text = "\(cartCount)"
                
                filterBtn.addSubview(lblBadge)
                
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: filterBtn)]
            }
        }
        
    }
    
    @objc func cartTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getWishlistProductsAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_WISHLIST, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    self.wishListArr.removeAll()
                    for i in 0..<json["metaData"]["items"].count
                    {
                        let currency = json["metaData"]["items"][i]["currency"].stringValue
                        let description = json["metaData"]["items"][i]["metaData"]["description"].stringValue
                        let category = json["metaData"]["items"][i]["category"].stringValue
                        let stock = json["metaData"]["items"][i]["stock"].stringValue
                        let productId = json["metaData"]["items"][i]["productId"].stringValue
                        let itemId = json["metaData"]["items"][i]["itemId"].stringValue
                        let price = json["metaData"]["items"][i]["price"].stringValue
                        let discountedPrice = json["metaData"]["items"][i]["discountedPrice"].stringValue
                        let rating = json["metaData"]["items"][i]["rating"].stringValue
                        
                        let discountPercent = json["metaData"]["items"][i]["discountValue"].stringValue
                        let name = json["metaData"]["items"][i]["name"].stringValue
                        //let images = json["metaData"]["items"][i]["metaData"]["images"][0].stringValue
                        
                        var imgArr = [String]()
                        for j in 0..<json["metaData"]["items"][i]["metaData"]["images"].count {
                            let file = json["metaData"]["items"][i]["metaData"]["images"][j].stringValue
                            imgArr.append(file)
                        }
                        
                        self.wishListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr))
                        
                    }
                    
                    if self.wishListArr.count > 0 {
                        self.wishlistCollectionView.isHidden = false
                        self.emptyView.isHidden = true
                        self.loginView.isHidden = true
                    } else {
                        self.wishlistCollectionView.isHidden = true
                        self.emptyView.isHidden = false
                        //self.loginView.isHidden = false
                    }
                    
                    DispatchQueue.main.async {
                        self.wishlistCollectionView.reloadData()
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
    
    func deleteApi(_ id: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "itemId": id]
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_DELETE_WISHLIST, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    //self.view.makeToast(json["message"].stringValue)
                    self.getWishlistProductsAPI()
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
    
    func getCartDetailOfUser() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_CART_DETAIL_OF_USER, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                let userId = json["userId"].stringValue
                //success == "true"
                if success == "true"
                {
                    UserDefaults.standard.setValue(json["cartId"].stringValue, forKey: USER_DEFAULTS_KEYS.CART_ID)
                    self.udCartId = json["cartId"].stringValue
                    UserDefaults.standard.setValue(json["userId"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_ID)
                    
                    if userId.count > 0 {
                        UserDefaults.standard.setValue(json["userId"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_ID)
                        cartProducts.removeAll()
                        self.dbItemsArr.removeAllObjects()
                        self.finalItemDic.removeAllObjects()
                        for i in 0..<json["metaData"]["items"].count
                        {
                            let productId =  json["metaData"]["items"][i]["productId"].stringValue
                            let itemId =  json["metaData"]["items"][i]["itemId"].stringValue
                            let quantity =  json["metaData"]["items"][i]["quantity"].stringValue
                            let discountPercent =  json["metaData"]["items"][i]["discountPercent"].stringValue
                            let name =  json["metaData"]["items"][i]["name"].stringValue
                            let price =  json["metaData"]["items"][i]["price"].stringValue
                            let stock =  json["metaData"]["items"][i]["stock"].stringValue
                            let discountedPrice =  json["metaData"]["items"][i]["discountedPrice"].stringValue
                            let currency =  json["metaData"]["items"][i]["currency"].stringValue
                            
                            let description =  json["metaData"]["items"][i]["metaData"]["description"].stringValue
                            
                            cartProducts.append(cartProductListStruct.init(currency: currency, description: description, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, name: name, quantity: quantity))
                            
                            let itemDic: NSMutableDictionary = NSMutableDictionary()
                            itemDic.setValue(productId, forKey: "productId")
                            itemDic.setValue(quantity, forKey: "quantity")
                            itemDic.setValue(itemId, forKey: "itemId")
                            
                            self.dbItemsArr.add(itemDic)
                        }
                        
                    }
                    
                    self.addTocartProcess()
                                                         
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
    
//    func addTocartProcess() {
//        if self.udCartId.count > 0 && UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
//
//            print("Update Cart")
//
//            if cartProducts[0].productId == self.productDetails.productId {
//
////                let count = (cartProducts[0].quantity as NSString).doubleValue
////
////                let itemDic: NSMutableDictionary = NSMutableDictionary()
////                itemDic.setValue(self.productDetails.productId, forKey: "productId")
////                itemDic.setValue("\(Int(count + 1))", forKey: "quantity")
////                itemDic.setValue(self.productDetails.itemId, forKey: "itemId")
////
////                self.dbItemsArr.add(itemDic)
////                self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
////
////                self.updateCartAPI()
//                self.view.makeToast("Product already exists in your cart. Go to cart in case you want to update Quantity or Checkout.")
//            } else {
//                self.view.makeToast("One product is already in your cart. Please proceed for checkout in order to save other product in cart.")
//            }
//
//        } else if self.udCartId.count == 0 && UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
//
//            print("save Cart")
//
//
//
//            if cartProducts.count == 0 {
//
//                self.dbItemsArr.removeAllObjects()
//                self.finalItemDic.removeAllObjects()
//
//                let itemDic: NSMutableDictionary = NSMutableDictionary()
//                itemDic.setValue(self.productDetails.productId, forKey: "productId")
//                itemDic.setValue("1", forKey: "quantity")
//                itemDic.setValue(self.productDetails.itemId, forKey: "itemId")
//
//                self.dbItemsArr.add(itemDic)
//
//                self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
//
//                self.saveCartApiCall()
//
//
//            } else {
//                self.view.makeToast("One product is already in your cart. Please proceed for checkout in order to save other product in cart.")
//            }
//
//        }
//    }
    
    func isProductInCart() -> Bool {
        var isExist = false
        
        for i in 0..<cartProducts.count {
            if self.productDetails.productId == cartProducts[i].productId {
                isExist = true
                break
            }
        }
        return isExist
    }
    
        func addTocartProcess() {
            if self.udCartId.count > 0 && UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
                        
                        print("Update Cart")
                        
                        if self.isProductInCart() {
                            self.view.makeToast("Product already exists in your cart. Go to cart in case you want to update Quantity or Checkout.")
                        } else {
                            let itemDic: NSMutableDictionary = NSMutableDictionary()
                            itemDic.setValue(self.productDetails.productId, forKey: "productId")
                            itemDic.setValue("1", forKey: "quantity")
                            itemDic.setValue(self.productDetails.itemId, forKey: "itemId")
                            
                            self.dbItemsArr.add(itemDic)
                            self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
                            self.updateCartAPI()
                        }
                        
                                    
            //            if cartProducts[0].productId == self.productDetails.productId {
            //
            //                //                let count = (cartProducts[0].quantity as NSString).doubleValue
            //                //
            //                //                let itemDic: NSMutableDictionary = NSMutableDictionary()
            //                //                itemDic.setValue(self.productDetails.productId, forKey: "productId")
            //                //                itemDic.setValue("\(Int(count + 1))", forKey: "quantity")
            //                //                itemDic.setValue(self.productDetails.itemId, forKey: "itemId")
            //                //
            //                //                self.dbItemsArr.add(itemDic)
            //                //                self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
            //                //
            //                //                self.updateCartAPI()
            //                self.view.makeToast("Product already exists in your cart. Go to cart in case you want to update Quantity or Checkout.")
            //            } else {
            //                self.view.makeToast("One product is already in your cart. Please proceed for checkout in order to save other product in cart.")
            //            }
                        
                    } else if self.udCartId.count == 0 && UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
                
                print("save Cart")
                
                
                    
                if cartProducts.count == 0 {
                    
                    self.dbItemsArr.removeAllObjects()
                    self.finalItemDic.removeAllObjects()
                    
                    let itemDic: NSMutableDictionary = NSMutableDictionary()
                    itemDic.setValue(self.productDetails.productId, forKey: "productId")
                    itemDic.setValue("1", forKey: "quantity")
                    itemDic.setValue(self.productDetails.itemId, forKey: "itemId")
                    
                    self.dbItemsArr.add(itemDic)
                    
                    self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
                    
                    self.saveCartApiCall()
                    
                    
                } else {
                    self.view.makeToast("One product is already in your cart. Please proceed for checkout in order to save other product in cart.")
                }
                
            }
        }
    
    func saveCartApiCall() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "metaData": self.finalItemDic]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_SAVE_CART, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    UserDefaults.standard.setValue(json["cartId"].stringValue, forKey: USER_DEFAULTS_KEYS.CART_ID)
                    self.udCartId = json["cartId"].stringValue
                    self.view.makeToast("Cart saved.")
                    UserDefaults.standard.set(self.dbItemsArr.count, forKey: "cartCount")
                    let cartCount = ["userInfo": ["cartCount": self.dbItemsArr.count]]
                    NotificationCenter.default
                        .post(name:           NSNotification.Name("updateCartBadge"),
                              object: nil,
                              userInfo: cartCount)
                    self.dbItemsArr.removeAllObjects()
                    self.finalItemDic.removeAllObjects()
                    self.deleteApi(self.itemIdToRemoveFromWishlist)
//                    UserDefaults.standard.set(1, forKey: "cartCount")
//                    let cartCount = ["userInfo": ["cartCount": 1]]
//                    NotificationCenter.default
//                        .post(name:           NSNotification.Name("updateCartBadge"),
//                              object: nil,
//                              userInfo: cartCount)
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
    
    func updateCartAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            var  apiUrl =  BASE_URL + PROJECT_URL.USER_UPDATE_CART
            apiUrl = apiUrl + "\(String(describing: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.CART_ID)!))"
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            let param:[String:Any] = [ "metaData": self.finalItemDic]
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    self.deleteApi(self.itemIdToRemoveFromWishlist)
                    UserDefaults.standard.set(self.dbItemsArr.count, forKey: "cartCount")
                    let cartCount = ["userInfo": ["cartCount": self.dbItemsArr.count]]
                    NotificationCenter.default
                        .post(name:           NSNotification.Name("updateCartBadge"),
                              object: nil,
                              userInfo: cartCount)
                    self.dbItemsArr.removeAllObjects()
                    self.finalItemDic.removeAllObjects()

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

    
    @IBAction func deleteAction(_ sender: UIButton) {
        let indexPath: IndexPath? = wishlistCollectionView.indexPathForItem(at: sender.convert(CGPoint.zero, to: wishlistCollectionView))
        let info = self.wishListArr[indexPath!.row]
        self.deleteApi(info.itemId)
    }
    
    @IBAction func cellAddToCartAction(_ sender: UIButton) {
        let indexPath: IndexPath? = wishlistCollectionView.indexPathForItem(at: sender.convert(CGPoint.zero, to: wishlistCollectionView))
        let info = self.wishListArr[indexPath!.row]
        self.itemIdToRemoveFromWishlist = info.itemId
        self.productDetails = categoryProductListStruct.init(currency: info.currency, description: info.description, category: info.category, stock: info.stock, productId: info.productId, itemId: info.itemId, price: info.price, discountedPrice: info.discountedPrice, discountPercent: info.discountPercent, rating: info.rating, name: info.name, images: info.images)

        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            self.getCartDetailOfUser()
        }
    }
    
    @IBAction func mainAddtoCartAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func loginAction(_ sender: Any) {
        isWishlistTab = "yes"
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func startSellingAction(_ sender: Any) {
        UserDefaults.standard.set("Sell", forKey: "userInterest")
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let viewController = userStoryboard.instantiateViewController(withIdentifier: "SellerLoginVC") as! SellerLoginVC
        UIApplication.shared.delegate!.window!!.rootViewController = viewController
    }
    
}

extension WishlistVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wishListArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WishlistCollCell", for: indexPath) as! WishlistCollCell
        let info = self.wishListArr[indexPath.row]
        cell.cellProductName.text = info.name
        cell.cellProductCost.text = info.discountedPrice
        if info.images!.count > 0 {
            cell.cellProductimg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.images![0])"), placeholderImage: UIImage(named: "edit cat_img"))
        }
        
        // cell.cellDocBtn.tag = indexPath.row
        //        cell.cellDocLbl.text = self.docLabelArr[indexPath.row] as? String
        //        cell.cellDocBtn.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
        //cell.setViewDocUploadCellData(docLabelArr, docValueArr: docUrlArr)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let info = self.wishListArr[indexPath.row]
        let itemID = info.itemId
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.itemID = itemID
        
        vc.productImgArr = info.images!
        vc.productID = info.productId
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.width
        return CGSize(width: collectionWidth / 2 - 10, height: collectionWidth / 2 + 80)
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let collectionWidth = collectionView.bounds.width
////        return CGSize(width: (UIScreen.main.bounds.size.width - 30) / 2.0, height: (UIScreen.main.bounds.size.height))
//        return CGSize(width: collectionWidth/2 - 10, height: collectionWidth/2 - 10)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
    
    
}
