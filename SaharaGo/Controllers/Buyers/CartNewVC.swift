//
//  CartNewVC.swift
//  SaharaGo
//
//  Created by Ritesh on 19/12/20.
//

import UIKit
import SQLite

class CartNewVC: UIViewController {
    
    @IBOutlet var totalLbl: UILabel!
    @IBOutlet var taxesLbl: UILabel!
    @IBOutlet var subTotalLbl: UILabel!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
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
    
    var dbItemsArr: NSMutableArray = NSMutableArray()
    var dbItemsArrCopy: NSMutableArray = NSMutableArray()
    var finalItemDic: NSMutableDictionary = NSMutableDictionary()
    var totalAmount : Double = Double()
    var searchProductListArr = [categoryProductListStruct]()
    var productDetailsArr = [cartProductListStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        
        self.createTable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        self.getDbProducts()
        self.getDb()
        
        self.navigationController?.navigationBar.isHidden = false
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            
            if isLogin == "yes" {
                self.getCartDetailOfUser()
            } else if isSignUp == "yes" {
                self.saveCartApiCall()
            } else {
                self.getCartDetailOfUser()
            }
            self.getDbProducts()
        } else {
            self.getDbProducts()
        }
    }
    
    
    func getDbProducts() {
        do {
            let notes = try self.database.prepare(self.productsTable)
            cartProducts.removeAll()
            dbProducts.removeAll()
            self.dbItemsArr.removeAllObjects()
            for note in notes {
                
                let prodId = note[self.prodId]
                let itemId = note[self.itemId]
                let prodName = note[self.prodName]
                let prodDesc = note[self.prodDescription]
                let prodStock = note[self.productStock]
                let productPrice = note[self.productPrice]
                let prodCurrency = note[self.prodCurrency]
                let prodDiscountPercent = note[self.prodDiscountPercent]
                let prodDiscountPrice = note[self.prodDiscountPrice]
                let prodCount = note[self.prodCount]
                let images = note[self.images]
                
                
               // cartProducts.append(cartProductListStruct.init(currency: prodCurrency, description: prodDesc, stock: prodStock, productId: prodId, itemId: itemId, price: productPrice, discountedPrice: prodDiscountPrice, discountPercent: prodDiscountPercent, name: prodName, quantity: "\(prodCount)"))
                
                dbProducts.append(cartProductListStruct.init(currency: prodCurrency, description: prodDesc, stock: prodStock, productId: prodId, itemId: itemId, price: productPrice, discountedPrice: prodDiscountPrice, discountPercent: prodDiscountPercent, name: prodName, quantity: "\(prodCount)", images: images))
                
                var itemDic: NSMutableDictionary = NSMutableDictionary()
                itemDic.setValue(prodId, forKey: "productId")
                itemDic.setValue("\(prodCount)", forKey: "quantity")
                itemDic.setValue(itemId, forKey: "itemId")
                
                self.dbItemsArr.add(itemDic)
                
            }
            
            self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
            print(self.finalItemDic)
            
            UserDefaults.standard.set(dbProducts.count, forKey: "cartCount")
            let cartCount = ["userInfo": ["cartCount": dbProducts.count]]
            NotificationCenter.default
                .post(name:           NSNotification.Name("updateCartBadge"),
                      object: nil,
                      userInfo: cartCount)
            
            if dbProducts.count > 0 {
                setPriceLbl(dbProducts)
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
            } else {
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
            
            //hit api get product detail by prodId .............
            
            
            
            
//            if cartProducts.count > 0 {
//                setPriceLbl()
//                self.tableView.isHidden = false
//                self.emptyView.isHidden = true
//            } else {
//                self.tableView.isHidden = true
//                self.emptyView.isHidden = false
//            }
//
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            
            
            
//            if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
//                if isSignUp == "yes" {
//                    self.saveCartApiCall()
//                }
//
//                if isLogin == "yes" {
//                    self.getCartDetailOfUser()
//                }
//            } else {
//                if cartProducts.count > 0 {
//                   // self.getProductDetailbyProdId()
//                }
//
//            }
            
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
    }
    
    func getCategoriesProductsList(catId: String, country: String, searchStr: String, pageNo: Int) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            //{country}/{pageNumber}/{limit}?categoryId=&search=&sort=
            var  apiUrl =  BASE_URL + PROJECT_URL.USER_GET_PRODUCTS
            apiUrl = apiUrl + "\(country)/" + "\(pageNo)/" + "100" + "?categoryId=\(catId)" + "&search=\(searchStr)" + "&sort="
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            
            // api/v1/user/getProducts/{country}/{pageNumber}/{limit}?categoryId=&search=&sort=
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.searchProductListArr.removeAll()
                    
                    for i in 0..<json["productList"].count
                    {
                        let currency = json["productList"][i]["currency"].stringValue
                        let description = json["productList"][i]["metaData"]["description"].stringValue
                        let category = json["productList"][i]["category"].stringValue
                        let stock = json["productList"][i]["stock"].stringValue
                        let actualPrice = json["productList"][i]["actualPrice"].stringValue
                        let productId = json["productList"][i]["productId"].stringValue
                        let itemId = json["productList"][i]["itemId"].stringValue
                        let price = json["productList"][i]["price"].stringValue
                        let discountedPrice = json["productList"][i]["discountedPrice"].stringValue
                        let rating = json["productList"][i]["rating"].stringValue
                        let wishlisted = json["productList"][i]["wishlisted"].boolValue
                        let discountPercent = json["productList"][i]["discountValue"].stringValue
                        let name = json["productList"][i]["name"].stringValue
                        //let images = json["productList"][i]["metaData"]["images"][0].stringValue
                        
                        var imgArr = [String]()
                        imgArr.removeAll()
                        for j in 0..<json["productList"][i]["metaData"]["images"].count {
                            let file = json["productList"][i]["metaData"]["images"][j].stringValue
                            imgArr.append(file)
                        }
                        
                        self.searchProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr, actualPrice: actualPrice, wishlisted: wishlisted))
                        
//                        searchProductListArrCopy = self.searchProductListArr
                        
                    }
                    
//                    print(self.searchProductListArr)
//                    self.isPagination = false
//                    if self.searchProductListArr.count > 0 {
//                        self.tableView.isHidden = false
//                        self.emptyView.isHidden = true
//                    } else {
//                        self.tableView.isHidden = true
//                        self.emptyView.isHidden = false
//                    }
//
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
                    
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
    
    func setPriceLbl(_ products: [cartProductListStruct]) {
        
        var total = 0.0
        
        for i in 0..<products.count {
            var price:Double = Double()
            var count:Double = Double()
            
            price = (products[i].discountedPrice as NSString).doubleValue
            count = (products[i].quantity as NSString).doubleValue
            
            let totalPrice = price * count
            total += totalPrice
        }
        
        DispatchQueue.main.async {
            self.totalAmount = total
            self.subTotalLbl.text = "USD \(total)"
            self.taxesLbl.text = "USD 0.0"
            self.totalLbl.text = "USD \(total)"
        }
                
    }
    
    func getProductDetailbyProdId() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            var apiurl = BASE_URL + PROJECT_URL.USER_GETPRODUCTDETAIL_BYPRODID
            apiurl = apiurl + "\(cartProducts[0].itemId)" + "?userId=\(UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.USER_ID) as! String)"
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: apiurl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    
                    //cartProducts.removeAll()
                    //self.dbItemsArr.removeAllObjects()
                    self.productDetailsArr.removeAll()
                    
                    let productId =  json["productId"].stringValue
                    let itemId =  json["itemId"].stringValue
                    let quantity =  json["quantity"].stringValue
                    let discountPercent =  json["discountPercent"].stringValue
                    let name =  json["name"].stringValue
                    let price =  json["price"].stringValue
                    let stock =  json["stock"].stringValue
                    let discountedPrice =  json["discountedPrice"].stringValue
                    let currency =  json["currency"].stringValue
                    
                    let description =  json["metaData"]["description"].stringValue
                    
//                    cartProducts.append(cartProductListStruct.init(currency: currency, description: description, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, name: name, quantity: quantity))
                    self.productDetailsArr.append(cartProductListStruct.init(currency: currency, description: description, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, name: name, quantity: quantity))
//                    if cartProducts.count > 0 {
//
//                        self.tableView.isHidden = false
//                        self.emptyView.isHidden = true
//                    } else {
//                        self.tableView.isHidden = true
//                        self.emptyView.isHidden = false
//                    }
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//
                    
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
    
    private func getDb() {
        do {
            let notes = try self.database.prepare(self.productsTable)
            cartProducts.removeAll()
            dbProducts.removeAll()
            self.dbItemsArr.removeAllObjects()
            for note in notes {
                
                let prodId = note[self.prodId]
                let itemId = note[self.itemId]
                let prodName = note[self.prodName]
                let prodDesc = note[self.prodDescription]
                let prodStock = note[self.productStock]
                let productPrice = note[self.productPrice]
                let prodCurrency = note[self.prodCurrency]
                let prodDiscountPercent = note[self.prodDiscountPercent]
                let prodDiscountPrice = note[self.prodDiscountPrice]
                let prodCount = note[self.prodCount]
                let images = note[self.images]
                
                
               // cartProducts.append(cartProductListStruct.init(currency: prodCurrency, description: prodDesc, stock: prodStock, productId: prodId, itemId: itemId, price: productPrice, discountedPrice: prodDiscountPrice, discountPercent: prodDiscountPercent, name: prodName, quantity: "\(prodCount)"))
                
                dbProductsCopy.append(cartProductListStruct.init(currency: prodCurrency, description: prodDesc, stock: prodStock, productId: prodId, itemId: itemId, price: productPrice, discountedPrice: prodDiscountPrice, discountPercent: prodDiscountPercent, name: prodName, quantity: "\(prodCount)", images: images))
                
                var itemDic: NSMutableDictionary = NSMutableDictionary()
                itemDic.setValue(prodId, forKey: "productId")
                itemDic.setValue("\(prodCount)", forKey: "quantity")
                itemDic.setValue(itemId, forKey: "itemId")
                
                self.dbItemsArrCopy.add(itemDic)
                
            }
        } catch {
            print("Error in func named getDb")
        }
        
    }
    
    private func isProductExistInCart(_ prodId: String) -> (Bool, Int) {
        var isExist = false
        var count = -1
        for i in 0..<cartProducts.count {
            count += 1
            let dbObj = cartProducts[i]
            if prodId == dbObj.itemId {
                isExist = true
                break
            }
        }
        return (isExist, count)
    }
    
    func getCartDetailOfUser() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_CART_DETAIL_OF_USER, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    UserDefaults.standard.setValue(json["cartId"].stringValue, forKey: USER_DEFAULTS_KEYS.CART_ID)
                    UserDefaults.standard.setValue(json["userId"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_ID)
                    self.dbItemsArr.removeAllObjects()
                    self.dbItemsArrCopy.removeAllObjects()
                    self.finalItemDic.removeAllObjects()
                    cartProducts.removeAll()
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
                        let currency = json["metaData"]["items"][i]["currency"].stringValue
                        
                        let description =  json["metaData"]["items"][i]["metaData"]["description"].stringValue
                        let images =  json["metaData"]["items"][i]["metaData"]["images"][0].stringValue
                        
                        
                        cartProducts.append(cartProductListStruct.init(currency: currency, description: description, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, name: name, quantity: quantity, images: images))
                        
                        let itemDic: NSMutableDictionary = NSMutableDictionary()
                        itemDic.setValue(productId, forKey: "productId")
                        itemDic.setValue(quantity, forKey: "quantity")
                        itemDic.setValue(itemId, forKey: "itemId")
                        
                        self.dbItemsArr.add(itemDic)
                        self.dbItemsArrCopy.add(itemDic)
                        
                    }
                    
                    UserDefaults.standard.set(cartProducts.count, forKey: "cartCount")
                    let cartCount = ["userInfo": ["cartCount": cartProducts.count]]
                    NotificationCenter.default
                        .post(name:           NSNotification.Name("updateCartBadge"),
                              object: nil,
                              userInfo: cartCount)
                    
                    if cartProducts.count > 0 {
                        if dbProducts.count > 0 {
                            
                            for i in 0..<dbProducts.count {
                                let dbInfo = dbProducts[i]
                                
                                let isExist = self.isProductExistInCart(dbInfo.itemId)
                                
                                if isExist.0 {
                                    
                                    //let dbCartInfo = dbInfo
                                    let cartInfo = cartProducts[isExist.1]
                                    
                                    let itemDic: NSMutableDictionary = NSMutableDictionary()
                                    itemDic.setValue(cartInfo.productId, forKey: "productId")
                                    itemDic.setValue(cartInfo.itemId, forKey: "itemId")
                                    let updatedCount = (cartInfo.quantity as NSString).doubleValue + (dbInfo.quantity as NSString).doubleValue
                                    itemDic.setValue(updatedCount, forKey: "quantity")
                                    print(self.dbItemsArrCopy)
                                    for j in 0..<self.dbItemsArrCopy.count {
                                        let obj = self.dbItemsArrCopy[j] as! NSMutableDictionary
                                        if dbInfo.itemId == obj.value(forKey: "itemId") as! String {
                                            obj["productId"] = cartInfo.productId
                                            obj["itemId"] = cartInfo.itemId
                                            obj["quantity"] = updatedCount
                                           // self.dbItemsArrCopy.remove(obj)
                                        }
                                    }
                                   // self.dbItemsArrCopy.removeObject(at: isExist.1)
                                   // self.dbItemsArrCopy.add(itemDic)
//                                    self.finalItemDic.setValue(dbItemsArrCopy, forKey: "items")
//                                    self.updateCartAPI()
                                    print(self.dbItemsArrCopy)
                                } else {
                                    let itemDic: NSMutableDictionary = NSMutableDictionary()
                                    itemDic.setValue(dbInfo.productId, forKey: "productId")
                                    itemDic.setValue(dbInfo.itemId, forKey: "itemId")
                                    itemDic.setValue(dbInfo.quantity, forKey: "quantity")
                                    self.dbItemsArrCopy.add(itemDic)
                                }
                            }
                            
                            self.finalItemDic.setValue(self.dbItemsArrCopy, forKey: "items")
                            print(self.finalItemDic)
                            self.updateCartAPI()
                            
                            
//                            self.dbItemsArr.removeAllObjects()
//                            self.finalItemDic.removeAllObjects()
                            
//                            let dbCartInfo = dbProducts[0]
//                            let cartInfo = cartProducts[0]
//                            let itemDic: NSMutableDictionary = NSMutableDictionary()
//
//
//                            if cartInfo.productId == dbCartInfo.productId {
//                                itemDic.setValue(cartInfo.productId, forKey: "productId")
//                                itemDic.setValue(cartInfo.itemId, forKey: "itemId")
//                                let updatedCount = (cartInfo.quantity as NSString).doubleValue + (dbCartInfo.quantity as NSString).doubleValue
//                                itemDic.setValue(updatedCount, forKey: "quantity")
//                                self.dbItemsArr.add(itemDic)
//                                self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
//                                self.updateCartAPI()
//                            } else {
//                                itemDic.setValue(cartInfo.productId, forKey: "productId")
//                                itemDic.setValue(cartInfo.itemId, forKey: "itemId")
//                                itemDic.setValue(cartInfo.quantity, forKey: "quantity")
//                                self.dbItemsArr.add(itemDic)
//                                self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
//                                //self.saveCartApiCall()
//                                self.updateCartAPI()
//                            }
                            
                        } else {
                            self.setPriceLbl(cartProducts)
                            self.tableView.isHidden = false
                            self.emptyView.isHidden = true
                        }
                    } else {
                        if dbProducts.count > 0 {
                            self.dbItemsArr.removeAllObjects()
                            self.finalItemDic.removeAllObjects()
                            
                            for i in 0..<dbProducts.count {
                                let dbCartInfo = dbProducts[i]
                                let itemDic: NSMutableDictionary = NSMutableDictionary()
                                itemDic.setValue(dbCartInfo.productId, forKey: "productId")
                                itemDic.setValue(dbCartInfo.itemId, forKey: "itemId")
                                itemDic.setValue(dbCartInfo.quantity, forKey: "quantity")
                                self.dbItemsArr.add(itemDic)
                                self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
                                
                            }
                            
                            self.saveCartApiCall()

                        } else {
                            self.tableView.isHidden = true
                            self.emptyView.isHidden = false
                        }
                    }
                 
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    isLogin = "no"
                                        
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
    
    
    
    func checkAndAddData(_ cartProdStruct: cartProductListStruct) -> Bool {
        print(dbItemsArr)
        var cartProdStructCopy = cartProdStruct
        var isExist: Bool = false
        var j = -1
        for i in 0..<cartProducts.count {
            j += 1
            if cartProducts[i].productId == cartProdStruct.productId {
                isExist = true
                let count = (cartProducts[i].quantity as NSString).doubleValue
                let updatedCount = (cartProdStruct.quantity as NSString).doubleValue + count
                
                
                var itemDic: NSMutableDictionary = NSMutableDictionary()
                var metaDataDic: NSMutableDictionary = NSMutableDictionary()
                itemDic.setValue(cartProdStruct.productId, forKey: "productId")
                itemDic.setValue(cartProdStruct.itemId, forKey: "itemId")
                itemDic.setValue("\(Int(updatedCount))", forKey: "quantity")
                
                cartProdStructCopy.quantity = "\(Int(updatedCount))"
                
                itemDic.setValue(cartProdStruct.name, forKey: "name")
                itemDic.setValue("", forKey: "category")
                itemDic.setValue(cartProdStruct.stock, forKey: "stock")
                itemDic.setValue(cartProdStruct.currency, forKey: "currency")
                itemDic.setValue(cartProdStruct.price, forKey: "price")
                itemDic.setValue(cartProdStruct.discountPercent, forKey: "discountPercent")
                itemDic.setValue(cartProdStruct.discountedPrice, forKey: "discountedPrice")
                
                metaDataDic.setValue(cartProdStruct.description, forKey: "description")
                metaDataDic.setValue([], forKey: "images")
                itemDic.setValue(metaDataDic, forKey: "metaData")
                
                cartProducts.remove(at: j)
                self.dbItemsArr.removeObject(at: j)
                
                self.dbItemsArr.add(itemDic)
                cartProducts.append(cartProdStructCopy)
                
                print(dbItemsArr)
                
            }
        }
        
        return isExist
        
    }
    
    func updateCartAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            var  apiUrl =  BASE_URL + PROJECT_URL.USER_UPDATE_CART
            apiUrl = apiUrl + "\(String(describing: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.CART_ID)!))"
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            //print(self.makeDicForParams())
            
            //            let param:[String:Any] = [ "metaData": self.finalItemDic]
            print(self.finalItemDic)
            let param:[String:Any] = [ "metaData": self.finalItemDic]
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    isLogin = "no"
                    self.deleteLocalProducts()
                    dbProducts.removeAll()
                    self.dbItemsArr.removeAllObjects()
                    self.setPriceLbl(cartProducts)
                    //                    cartProducts.removeAll()
                    self.getCartDetailOfUser()
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
    
    func deleteLocalProducts() {
        do {
            let users = Table("products")
            try self.database.run(users.delete())
            //try self.database.run(deleteNote)
            //self.getTodayNotes()
        } catch {
            #if DEBUG
            print(error)
            #endif
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
                    isSignUp = "no"
                    self.deleteLocalProducts()
                    dbProducts.removeAll()
                    self.view.makeToast("Cart saved.")
                    self.getCartDetailOfUser()
                    // Clear DB here.................
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
    
    @IBAction func checkoutAction(_ sender: Any) {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            if self.isOutOfStock() {
                self.view.makeToast("Ordered Item exceeds the Stock limit. Please visit the product detail page for the available stock enquiry.")
            } else {
                let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutVC
                vc.totalAmount = self.totalAmount
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func continueShoppingAction(_ sender: Any) {
        self.navigationController?.viewControllers.removeAll(where: { (vc) -> Bool in
            if vc.isKind(of: HomeNewVC.self) || vc.isKind(of: ProductDetailsVC.self) || vc.isKind(of: SearchProductsVC.self) || vc.isKind(of: CategoriesVC.self) || vc.isKind(of: WishlistVC.self) || vc.isKind(of: ProfileVC.self) || vc.isKind(of: ProfileDetailVC.self) {
                return true
            } else {
                return false
            }
        })
        
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "HomeNewVC") as! HomeNewVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func isOutOfStock() -> Bool {
        var outOfStock = false
//        if cartProducts[0].productId == self.productDetailsArr[0].productId {
//            if cartProducts[0].quantity > productDetailsArr[0].stock {
//                outOfStock = true
//            }
//        }
        
        if (cartProducts[0].quantity as NSString).doubleValue > (cartProducts[0].stock as NSString).doubleValue {
            outOfStock = true
        }
        
        return outOfStock
    }
    
    @IBAction func cellDeleteAction(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
            let tappedObj = self.dbItemsArr[indexPath!.row] as! NSMutableDictionary
            self.removeCartItemsAPI(tappedObj.value(forKey: "itemId") as! String, index: indexPath!.row)
        } else {
            let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
            let noteId = indexPath!.row
            let info = dbProducts[indexPath!.row]
//            let note = self.productsTable.filter(id == noteId + 1)
            let note = self.productsTable.filter(self.prodId == info.productId)
            let deleteNote = note.delete()
            
            do {
                try self.database.run(deleteNote)
                
               // dbProducts.remove(at: noteId)
                self.getDbProducts()
//                if dbProducts.count == 0 {
//                    self.tableView.isHidden = true
//                    self.emptyView.isHidden = false
//                }
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
                
//                UserDefaults.standard.set(0, forKey: "cartCount")
//                let cartCount = ["userInfo": ["cartCount": 0]]
//                NotificationCenter.default
//                    .post(name:           NSNotification.Name("updateCartBadge"),
//                          object: nil,
//                          userInfo: cartCount)
                
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
        }
        
        
    }
    
    @IBAction func cellIncreamentAction(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
            
//            self.dbItemsArr.removeAllObjects()
//            self.finalItemDic.removeAllObjects()
//            let cartInfo = cartProducts[indexPath!.row]
//            let itemDic: NSMutableDictionary = NSMutableDictionary()
//            let updatedCount = (cartInfo.quantity as NSString).doubleValue + 1
//            itemDic.setValue(cartInfo.productId, forKey: "productId")
//            itemDic.setValue(cartInfo.itemId, forKey: "itemId")
//            itemDic.setValue("\(Int(updatedCount))", forKey: "quantity")
//            cartProducts[indexPath!.row].quantity = "\(Int(updatedCount))"
//            self.dbItemsArr.add(itemDic)
//            self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
            
            let tappedObj = self.dbItemsArr[indexPath!.row] as! NSMutableDictionary
            let updatedCount = (tappedObj.value(forKey: "quantity") as! NSString).doubleValue + 1
            for items in self.dbItemsArr {
                let item = items as! NSMutableDictionary
                if tappedObj.value(forKey: "productId") as! NSString == item.value(forKey: "productId") as! NSString {
                    item["quantity"] = "\(Int(updatedCount))"
                    break
                }
            }
            self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
            self.updateCartAPI()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
             let prodId = indexPath!.row
            let info = dbProducts[indexPath!.row]
            // let note = self.productsTable.filter(self.id == prodId + 1)
            let product = self.productsTable.filter(self.prodId == info.productId)
                                                    
             let updateProduct = product.update(self.prodCount <- prodCount + 1)
             do{
                 try self.database.run(updateProduct)
                 self.getDbProducts()
             } catch {
                 #if DEBUG
                 print(error)
                 #endif
             }
        }
        
        
        
    }
    
    @IBAction func cellDecremanetAction(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
            
//            self.dbItemsArr.removeAllObjects()
//            self.finalItemDic.removeAllObjects()
//            let cartInfo = cartProducts[0]
//            let itemDic: NSMutableDictionary = NSMutableDictionary()
//            let updatedCount = (cartInfo.quantity as NSString).doubleValue - 1
//            itemDic.setValue(cartInfo.productId, forKey: "productId")
//            itemDic.setValue(cartInfo.itemId, forKey: "itemId")
//            itemDic.setValue("\(Int(updatedCount))", forKey: "quantity")
//            cartProducts[0].quantity = "\(Int(updatedCount))"
//            self.dbItemsArr.add(itemDic)
//            self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
            
            let tappedObj = self.dbItemsArr[indexPath!.row] as! NSMutableDictionary
            let updatedCount = (tappedObj.value(forKey: "quantity") as! NSString).doubleValue - 1
            for items in self.dbItemsArr {
                let item = items as! NSMutableDictionary
                if tappedObj.value(forKey: "productId") as! NSString == item.value(forKey: "productId") as! NSString {
                    if Int(updatedCount) < 1 {
                        self.dbItemsArr.remove(item)
                        break
                    } else {
                        item["quantity"] = "\(Int(updatedCount))"
                        break
                    }
                    
                }
            }
            self.finalItemDic.setValue(self.dbItemsArr, forKey: "items")
            print(self.dbItemsArr)
            self.updateCartAPI()
            
//            if Int(cartProducts[0].quantity)! < 1 {
//                self.tableView.isHidden = true
//                self.emptyView.isHidden = false
//                self.deleteLocalProducts()
//                self.removeCartItemsAPI()
//
//            } else {
//                self.updateCartAPI()
//            }
            
            
            

            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
             let prodId = indexPath!.row
            let info = dbProducts[indexPath!.row]
            // let note = self.productsTable.filter(self.id == prodId + 1)
            let product = self.productsTable.filter(self.prodId == info.productId)
             let updateProduct = product.update(self.prodCount <- prodCount - 1)
             do{
                
                if Int(info.quantity) == 1 {
                    let note = self.productsTable.filter(self.prodId == info.productId)
                    let deleteNote = note.delete()
                    try self.database.run(deleteNote)
                } else {
                    try self.database.run(updateProduct)
                }
//                 try self.database.run(updateProduct)
                 self.getDbProducts()
                
                if dbProducts.count == 0 {
                    self.tableView.isHidden = true
                    self.emptyView.isHidden = false
                    self.deleteLocalProducts()
                }
                
//                 if Int(dbProducts[0].quantity)! < 1 {
//                     self.tableView.isHidden = true
//                     self.emptyView.isHidden = false
//                     self.deleteLocalProducts()
//
//                 }
             } catch {
                 #if DEBUG
                 print(error)
                 #endif
             }
        }
        
        
    }
    
    func removeCartItemsAPI(_ itemToRemove: String, index: Int) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            var apiUrl = BASE_URL + PROJECT_URL.USER_REMOVE_ITEM_FROM_CART
            apiUrl = apiUrl + "\(UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.CART_ID) ?? "")" + "/\(itemToRemove)"
            
            let param:[String:Any] = [:]
            
            ServerClass.sharedInstance.putRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    
                    cartProducts.remove(at: index)
                    self.getCartDetailOfUser()
                    
                    
                    
                    
//                    cartProducts.removeAll()
//                    self.deleteLocalProducts()
//                    dbProducts.removeAll()
//                    if cartProducts.count > 0 {
//                        self.tableView.isHidden = false
//                        self.emptyView.isHidden = true
//                    } else {
//                        self.tableView.isHidden = true
//                        self.emptyView.isHidden = false
//                    }
//
//                    UserDefaults.standard.set(0, forKey: "cartCount")
//                    let cartCount = ["userInfo": ["cartCount": 0]]
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
    
}

extension CartNewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            return cartProducts.count
        } else {
            return dbProducts.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            let info = cartProducts[indexPath.row]
            cell.setCartData(info)
        } else {
            let info = dbProducts[indexPath.row]
            cell.setCartData(info)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    
}
