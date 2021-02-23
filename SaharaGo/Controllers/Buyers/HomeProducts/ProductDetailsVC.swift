//
//  ProductDetailsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 16/12/20.
//

import UIKit
import SQLite
import Cosmos

struct rating_struct {
    var rating: Double = 0.00
    var review: String = ""
    var fromId: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var userImage: String = ""
    
}

class ProductDetailsVC: UIViewController {
    
    var database : Connection!
    let productsTable = Table("products")
    let id = Expression<Int>("id")
    let prodName = Expression<String>("prodName")
    let prodDescription = Expression<String>("prodDescription")
    let productStock = Expression<String>("prodStock")
    let productPrice = Expression<String>("prodPrice")
    let prodCurrency = Expression<String>("prodCurrency")
    let prodDiscountPercent = Expression<String>("prodDiscountPercent")
    let prodDiscountPrice = Expression<String>("prodDiscountPrice")
    let prodCount = Expression<Int>("prodCount")
    let prodId = Expression<String>("prodId")
    let itemId = Expression<String>("itemId")
    let images = Expression<String>("images")
    
    var udCartId = ""
    
    var dbItemsArr: NSMutableArray = NSMutableArray()
    var finalItemDic: NSMutableDictionary = NSMutableDictionary()
    
    @IBOutlet var soldByLbl: UILabel!
    @IBOutlet var addToCartBtn: UIButton!
    @IBOutlet var reviewsLbl: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var prodDscription: UILabel!
    @IBOutlet var prodStock: UILabel!
    @IBOutlet var prodPrice: UILabel!
    @IBOutlet var prodTitle: UILabel!
    @IBOutlet var prodImg: UIImageView!
    @IBOutlet var prodDiscountLbl: UILabel!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var wishlistBtn: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    
    var productDetails = categoryProductListStruct()
    var productRatingArr = [rating_struct]()
    var itemID: String?
    var productID: String?
    var productImgArr: [String] = [String]()
    var productImgStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getProductRating()
        
        do {
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let fileUrl = documentDirectory.appendingPathComponent("Sahara").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
            
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        if let itemID = self.itemID {
            if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.USER_ID) != nil {
                getItemByItemID(itemID: itemID, userId: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.USER_ID) as! String)
            } else {
                getItemByItemID(itemID: itemID, userId: "")
            }
            
        }
        
        
        self.productTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.createTable()
        if self.productDetails.images != nil{
            if self.productDetails.images!.count > 0{
                self.productImgArr = self.productDetails.images!
            }
        }
        
        if self.productImgArr.count > 0 {
            self.pageControl.isHidden = false
            self.pageControl.numberOfPages = self.productImgArr.count
        } else {
            self.pageControl.isHidden = true
        }
        
        self.collectionView.reloadData()
        
        self.navigationController?.navigationBar.isHidden = false
        // navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "cart"), style: .plain, target: self, action: #selector(cartTapped))
        
        self.tabBarController?.tabBar.isHidden = false
        isWishlist = "no"
        self.makeNavCartBtn()
    }
    
//    @objc func updateCartBadge(_ notification: Notification) {
//        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
//            if cartCount == 0 {
//                self.cartBadgeLbl.isHidden = true
//            } else {
//                self.cartBadgeLbl.isHidden = false
//                let cartCountDic = notification.userInfo?["userInfo"] as? [String: Any] ?? [:]
//                self.cartBadgeLbl.text = "\(String(describing: cartCountDic["cartCount"]!))"
//            }
//        }
//
//
//    }
    
    @objc func cartTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func makeNavCartBtn() {
        
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "cart"), style: .plain, target: self, action: #selector(cartTapped))
                
            } else {
                
                let filterBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
                filterBtn.setImage(UIImage.init(named: "cart"), for: .normal)
                filterBtn.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
                
                let lblBadge = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 15, height: 15))
                lblBadge.backgroundColor = UIColor.red
                lblBadge.clipsToBounds = true
                lblBadge.layer.cornerRadius = 7
                lblBadge.textColor = UIColor.white
                // lblBadge.font = FontLatoRegular(s: 10)
                lblBadge.textAlignment = .center
                lblBadge.text = "\(cartCount)"
                
                filterBtn.addSubview(lblBadge)
                
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: filterBtn)]
            }
        }
        
        
        
        
    }
    
    func createTable() {
        
        let createNotesTable = productsTable.create { (table) in
            table.column(id, primaryKey: true)
            table.column(self.prodName)
            table.column(self.prodDescription)
            table.column(self.productStock)
            table.column(self.productPrice)
            table.column(self.prodCurrency)
            table.column(self.prodDiscountPercent)
            table.column(self.prodDiscountPrice)
            table.column(self.prodCount)
            table.column(self.prodId)
            table.column(self.itemId)
            table.column(self.images)
        }
        
        do {
            try self.database.run(createNotesTable)
            print("notes table created.")
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
    }
    
    @IBAction func wishlistAction(_ sender: Any) {
        isWishlist = "yes"
        
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil && !productDetails.wishlisted {
            self.wishlistBtn.setImage(UIImage(named: "fill heart"), for: .normal)
            productDetails.wishlisted = true
            self.addProductToWishlistAPI()
            
        } else if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil && productDetails.wishlisted {
            self.wishlistBtn.setImage(UIImage(named: "heart_deselect"), for: .normal)
            productDetails.wishlisted = false
            self.deleteApi(productDetails.itemId)
            
        } else {
            
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
            
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
                    self.view.makeToast(json["message"].stringValue)
                    
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
    
    func addProductToWishlistAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = [ "itemId": self.productDetails.itemId]
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_ADD_TO_WISHLIST, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    //save data in userdefault..
                    self.view.makeToast("Product added to Wishlist.")
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
    
    
    
    
    @IBAction func requestQuoteAction(_ sender: Any) {
    }
    
    @IBAction func addToCartAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "Add to Cart" {
                
                if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
                    self.getCartDetailOfUser()
                } else {
                    if SqliteManager.sharedInstance.matchProducts(self.productDetails.productId) {
                        
                        //                let product = self.productsTable.filter(self.prodId == self.productDetails.productId)
                        //                let updateProduct = product.update(self.prodCount <- prodCount + 1)
                        //                do{
                        //                    try self.database.run(updateProduct)
                        //                    self.view.makeToast("Product updated Successfully.")
                        //                } catch {
                        //                    #if DEBUG
                        //                    print(error)
                        //                    #endif
                        //                }
                        self.view.makeToast("Product already exists in your cart. Go to cart in case you want to update Quantity or Checkout.")
                        
                    } else if Int(self.productDetails.stock)! <= 0 {
                        
                        self.view.makeToast("Product is out of Stock.")
                    } else {
                        
        //                if SqliteManager.sharedInstance.fetchDbCount() > 0 {
        //                    self.view.makeToast("One product is already in your cart. Please proceed for checkout in order to save other product in cart.")
        //                } else
                        
                            
                        let insertProduct = self.productsTable.insert(self.prodName <- self.productDetails.name, self.prodDescription <- self.productDetails.description, self.productStock <- self.productDetails.stock, self.productPrice <- self.productDetails.discountedPrice, self.prodCurrency <- self.productDetails.currency, self.prodDiscountPercent <- self.productDetails.discountPercent, self.prodDiscountPrice <- self.productDetails.discountedPrice, self.prodCount <- 1, self.prodId <- self.productDetails.productId, self.itemId <- self.productDetails.itemId, self.images <- self.productImgArr[0])
                            do {
                                try self.database.run(insertProduct)
                                print("notes table created.")
                                self.view.makeToast("Product added Successfully.")
                                UserDefaults.standard.set(SqliteManager.sharedInstance.fetchDbCount(), forKey: "cartCount")
                                let cartCount = ["userInfo": ["cartCount": SqliteManager.sharedInstance.fetchDbCount()]]
                                NotificationCenter.default
                                    .post(name:           NSNotification.Name("updateCartBadge"),
                                          object: nil,
                                          userInfo: cartCount)
                                self.makeNavCartBtn()
                            } catch {
                                #if DEBUG
                                print(error)
                                #endif
                            }
                        
                        
                    }
                }
                
                sender.setTitle("Go To Cart", for: .normal)
                //self.addToCartBtn.setTitle("Go To Cart", for: .normal)
        } else {
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getItemByItemID(itemID: String, userId: String){
        
        if Reachability.isConnectedToNetwork(){
            
            showProgressOnView(appDelegateInstance.window!)
            
            ServerClass.sharedInstance.getRequestWithUrlParameters([:], path: BASE_URL + PROJECT_URL.GET_PRODUCT_BY_ITEM_ID + itemID + "?userId=\(userId)", successBlock: { (response) in
                
                print(response)
                
                let currency = response["currency"].stringValue
                let description = response["metaData"]["description"].stringValue
                let category = response["categoryId"].stringValue
                let stock = response["stock"].stringValue
                let vendorName = response["vendorName"].stringValue
                let productID = response["productId"].stringValue
                let itemID = response["itemId"].stringValue
                let discountedPrice = response["discountedPrice"].stringValue
                let discountPercent = response["discountValue"].stringValue
                let price = response["price"].stringValue
                let rating = response["rating"].stringValue
                let name = response["name"].stringValue
                let wishlisted = response["wishlisted"].boolValue
                
                let product = categoryProductListStruct(currency: currency, description: description, category: category, stock: stock, vendorName: vendorName, productId: productID, itemId: itemID, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, wishlisted: wishlisted)
                
                self.productDetails = product
                
                self.ratingView.rating = Double(self.productDetails.rating)!
                self.ratingView.settings.updateOnTouch = false
                self.ratingView.settings.fillMode = .precise
                
                self.setDetails()
                hideAllProgressOnView(appDelegateInstance.window!)
            }) { (error) in
                hideAllProgressOnView(appDelegateInstance.window!)
                print(error.localizedDescription)
            }
        }
        
    }
    
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
                UserDefaults.standard.set(self.dbItemsArr.count, forKey: "cartCount")
                let cartCount = ["userInfo": ["cartCount": self.dbItemsArr.count]]
                NotificationCenter.default
                    .post(name:           NSNotification.Name("updateCartBadge"),
                          object: nil,
                          userInfo: cartCount)
                
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
            
            if Int(self.productDetails.stock)! <= 0 {
                self.view.makeToast("Product is Out of Stock.")
            } else {
                if cartProducts.count == 0 {
                    
                    self.dbItemsArr.removeAllObjects()
                    self.finalItemDic.removeAllObjects()
                    
                    let itemDic: NSMutableDictionary = NSMutableDictionary()
                    itemDic.setValue(self.productDetails.productId, forKey: "productId")
                    itemDic.setValue("1", forKey: "quantity")
                    itemDic.setValue(self.productDetails.itemId, forKey: "itemId")
                    
                    self.dbItemsArr.add(itemDic)
                    UserDefaults.standard.set(self.dbItemsArr.count, forKey: "cartCount")
                    let cartCount = ["userInfo": ["cartCount": self.dbItemsArr.count]]
                    NotificationCenter.default
                        .post(name:           NSNotification.Name("updateCartBadge"),
                              object: nil,
                              userInfo: cartCount)
                    
                    self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
                    
                    self.saveCartApiCall()
                    
                    
                } else {
                    self.view.makeToast("One product is already in your cart. Please proceed for checkout in order to save other product in cart.")
                }
                
            }
            
        } else if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) == nil {
            if SqliteManager.sharedInstance.matchProducts(self.productDetails.productId) {
                
                // let noteId = self.eventDic.value(forKey: "noteId") as! Int
                let product = self.productsTable.filter(self.prodId == self.productDetails.productId)
                let updateProduct = product.update(self.prodCount <- prodCount + 1)
                do{
                    try self.database.run(updateProduct)
                    self.view.makeToast("Product updated Successfully.")
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                }
                
            } else {
                
                if SqliteManager.sharedInstance.fetchDbCount() > 0 {
                    self.view.makeToast("One product is already in your cart. Please proceed for checkout in order to save other product in cart.")
                } else {
                    
                    let insertProduct = self.productsTable.insert(self.prodName <- self.productDetails.name, self.prodDescription <- self.productDetails.description, self.productStock <- self.productDetails.stock, self.productPrice <- self.productDetails.discountedPrice, self.prodCurrency <- self.productDetails.currency, self.prodDiscountPercent <- self.productDetails.discountPercent, self.prodDiscountPrice <- self.productDetails.discountedPrice, self.prodCount <- 1, self.prodId <- self.productDetails.productId, self.itemId <- self.productDetails.itemId)
                    do {
                        try self.database.run(insertProduct)
                        print("notes table created.")
                        self.view.makeToast("Product added Successfully.")
                    } catch {
                        #if DEBUG
                        print(error)
                        #endif
                    }
                }
                
            }
        }
    }
    
    private func setDetails() {
        self.prodTitle.text = self.productDetails.name
        self.prodPrice.text = "\(self.productDetails.currency) \(self.productDetails.discountedPrice)"
        self.prodStock.text = "Stock: \(self.productDetails.stock)"
        self.soldByLbl.text = "Sold By: \(self.productDetails.vendorName)"
        self.prodDscription.text = self.productDetails.description
        self.prodDiscountLbl.text = "\(self.productDetails.discountPercent)% OFF"
        if self.productDetails.wishlisted {
            self.wishlistBtn.setImage(UIImage(named: "fill heart"), for: .normal)
        } else {
            self.wishlistBtn.setImage(UIImage(named: "heart_deselect"), for: .normal)
        }
        
        productTableView.layoutTableHeaderView()
        /*
         if self.productImgArr.count > 0 {
         self.prodImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(self.productImgArr[0])"), placeholderImage: UIImage(named: "edit cat_img"))
         }*/
        
        //        let rating = self.productDetails.rating
        //        self.ratingView.rating = Double(rating)!
        //        self.ratingView.settings.updateOnTouch = false
        //        self.ratingView.settings.fillMode = .precise
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
                    
                    UserDefaults.standard.set(cartProducts.count, forKey: "cartCount")
                    let cartCount = ["userInfo": ["cartCount": cartProducts.count]]
                    NotificationCenter.default
                        .post(name:           NSNotification.Name("updateCartBadge"),
                              object: nil,
                              userInfo: cartCount)
                    self.makeNavCartBtn()
                    
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
                    self.dbItemsArr.removeAllObjects()
                    self.finalItemDic.removeAllObjects()
                    
                  //  UserDefaults.standard.set(1, forKey: "cartCount")
//                    let cartCount = ["userInfo": ["cartCount": 1]]
//                    NotificationCenter.default
//                        .post(name:           NSNotification.Name("updateCartBadge"),
//                              object: nil,
//                              userInfo: cartCount)
                    self.makeNavCartBtn()
                    
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
//                    let cartCount = ["userInfo": ["cartCount": self.dbItemsArr.count]]
//                    NotificationCenter.default
//                        .post(name:           NSNotification.Name("updateCartBadge"),
//                              object: nil,
//                              userInfo: cartCount)
                    UserDefaults.standard.set(self.dbItemsArr.count, forKey: "cartCount")
                    self.dbItemsArr.removeAllObjects()
                    self.finalItemDic.removeAllObjects()
                    
                    
                   // UserDefaults.standard.set(cartProducts.count, forKey: "cartCount")
//                    let cartCount = ["userInfo": ["cartCount": cartProducts.count]]
//                    NotificationCenter.default
//                        .post(name:           NSNotification.Name("updateCartBadge"),
//                              object: nil,
//                              userInfo: cartCount)
                    self.makeNavCartBtn()
                    
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
    
    func getProductRating() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            var apiUrl =  BASE_URL + PROJECT_URL.USER_GET_RATING_DETAILS
            apiUrl = apiUrl + "\(String(describing: self.itemID!))"
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    for i in 0..<json["ratingList"].count {
                        
                        let rating = json["ratingList"][i]["rating"].doubleValue
                        let review = json["ratingList"][i]["review"].stringValue
                        let fromId = json["ratingList"][i]["fromId"].stringValue
                        let firstName = json["ratingList"][i]["userMetaData"]["firstName"].stringValue
                        let lastName = json["ratingList"][i]["userMetaData"]["lastName"].stringValue
                        let userImage = json["ratingList"][i]["userMetaData"]["image"].stringValue
                        
                        
                        self.productRatingArr.append(rating_struct.init(rating: rating, review: review, fromId: fromId, firstName: firstName, lastName: lastName, userImage: userImage))
                    }
                    
                    if self.productRatingArr.count > 0 {
                        self.reviewsLbl.isHidden = false
                    }
                    
                    DispatchQueue.main.async {
                        self.productTableView.reloadData()
                    }
                    
                    
//                    self.ratingView.rating = Double(truncating: NSNumber(value: rating))
//                    self.ratingView.settings.updateOnTouch = false
//                    self.ratingView.settings.fillMode = .precise
                    
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

extension ProductDetailsVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productImgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeNewBannerCollCell", for: indexPath) as! HomeNewBannerCollCell
        cell.cellImg.layer.masksToBounds = true
        cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(self.productImgArr[indexPath.row])"), placeholderImage: UIImage(named: "edit cat_img"))
        //self.pagecontrol.currentPage = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
}

extension ProductDetailsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productRatingArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductRatingCell", for: indexPath) as! ProductRatingCell
        let info = self.productRatingArr[indexPath.row]
        
//        if cell.cellImg.width > cell.cellImg.height {
//            cell.cellImg.contentMode = .scaleAspectFit
//            //since the width > height we may fit it and we'll have bands on top/bottom
//        } else {
//            cell.cellImg.contentMode = .scaleAspectFill
//          //width < height we fill it until width is taken up and clipped on top/bottom
//        }
        
        cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.userImage)"), placeholderImage: UIImage(named: "profile"))
        cell.cellName.text = "\(info.firstName) \(info.lastName)"
        cell.cellDescLbl.text = info.review
        cell.cellRatingView.rating = info.rating
        cell.cellRatingView.settings.fillMode = .precise
        cell.cellRatingView.settings.updateOnTouch = false
        
        return cell
    }
    
}
