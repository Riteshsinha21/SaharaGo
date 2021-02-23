//
//  CartVC.swift
//  SaharaGo
//
//  Created by Ritesh on 16/12/20.
//

import UIKit
import SQLite

struct cartItem_ListStruct {
    var productId:String = ""
    var quantity:String = ""
}

class CartVC: UIViewController {
    
    @IBOutlet var taxesLbl: UILabel!
    @IBOutlet var totalLbl: UILabel!
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
    let images = Expression<String>("images")
    
    
    var cartitemListApiProducts = [cartItem_ListStruct]()
    var itemsArr: NSMutableArray = NSMutableArray()
    
    var finalItemDic: NSMutableDictionary = NSMutableDictionary()
    
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
        
        self.getProducts()
        self.navigationController?.navigationBar.isHidden = false
        
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.CART_ID) != nil {
            self.getCartDetailOfUser()
        }
        
        self.setPriceLbl()
    }
    
    func setPriceLbl() {
        
//        var totalPrice: Double = 0.0
//        for items in self.itemsArr {
//            let item = items as! NSDictionary
//            let discountedPrice = (item.value(forKey: "discountedPrice") as! NSString).doubleValue
//            let quantity = (item.value(forKey: "quantity") as! NSString).doubleValue
//            let priceForOneItem = discountedPrice * quantity
//            totalPrice = totalPrice + priceForOneItem
//            
//        }
//      
//        self.totalLbl.text = "\(totalPrice)"
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        
//        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
//        let noteId = indexPath!.row
//        let note = self.productsTable.filter(self.id == noteId + 1)
//        let deleteNote = note.delete()
//
//        do {
//            try self.database.run(deleteNote)
//            self.getProducts()
//        } catch {
//            #if DEBUG
//            print(error)
//            #endif
//        }
        
    }
    
    func createTable() {
        
        let createNotesTable = productsTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.prodName)
            table.column(self.prodDescription)
            table.column(self.productStock)
            table.column(self.productPrice)
            table.column(self.prodCurrency)
            table.column(self.prodDiscountPercent)
            table.column(self.prodDiscountPrice)
            table.column(self.prodCount)
            table.column(self.prodId)
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
    
    func getProducts() {
        do {
            let notes = try self.database.prepare(self.productsTable)
            
            
            print(cartProducts)
            print(self.itemsArr)
            print(self.finalItemDic)
            cartProducts.removeAll()
            self.itemsArr.removeAllObjects()
            for note in notes {
                
                let prodId = note[self.prodId]
                let prodName = note[self.prodName]
                let prodDesc = note[self.prodDescription]
                let prodStock = note[self.productStock]
                let productPrice = note[self.productPrice]
                let prodCurrency = note[self.prodCurrency]
                let prodDiscountPercent = note[self.prodDiscountPercent]
                let prodDiscountPrice = note[self.prodDiscountPrice]
                let prodCount = note[self.prodCount]
                
                cartProducts.append(cartProductListStruct.init(currency: prodCurrency, description: prodDesc, stock: prodStock, productId: prodId, price: productPrice, discountedPrice: prodDiscountPrice, discountPercent: prodDiscountPercent, name: prodName, quantity: "\(prodCount)"))
            
                //self.makeData(cartProducts)
                var itemDic: NSMutableDictionary = NSMutableDictionary()
                var metaDataDic: NSMutableDictionary = NSMutableDictionary()
                itemDic.setValue(prodId, forKey: "productId")
                itemDic.setValue("\(prodCount)", forKey: "quantity")
            
                itemDic.setValue(prodName, forKey: "name")
                itemDic.setValue("", forKey: "category")
                itemDic.setValue(prodStock, forKey: "stock")
                itemDic.setValue(prodCurrency, forKey: "currency")
                itemDic.setValue(productPrice, forKey: "price")
                itemDic.setValue(prodDiscountPercent, forKey: "discountPercent")
                itemDic.setValue(prodDiscountPrice, forKey: "discountedPrice")
            
                metaDataDic.setValue(prodDesc, forKey: "description")
                metaDataDic.setValue([], forKey: "images")
                itemDic.setValue(metaDataDic, forKey: "metaData")
                
                print(self.itemsArr)
                self.itemsArr.add(itemDic)
                print(self.itemsArr)

            }
            print(cartProducts)
            if cartProducts.count > 0 {
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
            } else {
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            }
            self.finalItemDic.setValue(self.itemsArr, forKey: "items")
            print(self.finalItemDic)

            if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
                if isSignUp == "yes" {
                    self.saveCartApiCall()
                }
                
                if isLogin == "yes" {
                    self.getCartDetailOfUser()
                }
            }
            
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
                        cartProducts.removeAll()
                        if json["cartId"].stringValue.count > 0 {
                            UserDefaults.standard.setValue(json["cartId"].stringValue, forKey: USER_DEFAULTS_KEYS.CART_ID)
                            UserDefaults.standard.setValue(json["userId"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_ID)
                            
                            for i in 0..<json["metaData"]["items"].count
                            {
                                let productId =  json["metaData"]["items"][i]["productId"].stringValue
                                let quantity =  json["metaData"]["items"][i]["quantity"].stringValue
                                let discountPercent =  json["metaData"]["items"][i]["discountPercent"].stringValue
                                let name =  json["metaData"]["items"][i]["name"].stringValue
                                let price =  json["metaData"]["items"][i]["price"].stringValue
                                let stock =  json["metaData"]["items"][i]["stock"].stringValue
                                let discountedPrice =  json["metaData"]["items"][i]["discountedPrice"].stringValue
                                let currency =  json["metaData"]["items"][i]["currency"].stringValue
                                
                                let description =  json["metaData"]["items"][i]["metaData"]["description"].stringValue
                                
                                
                                cartProducts.append(cartProductListStruct.init(currency: currency, description: description, stock: stock, productId: productId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, name: name, quantity: quantity))
                                
                                
                                var itemDic: NSMutableDictionary = NSMutableDictionary()
                                var metaDataDic: NSMutableDictionary = NSMutableDictionary()
                                    itemDic.setValue(productId, forKey: "productId")
                                    itemDic.setValue("\(quantity)", forKey: "quantity")
                                
                                    itemDic.setValue(name, forKey: "name")
                                    itemDic.setValue("", forKey: "category")
                                    itemDic.setValue(stock, forKey: "stock")
                                    itemDic.setValue(currency, forKey: "currency")
                                    itemDic.setValue(price, forKey: "price")
                                    itemDic.setValue(discountPercent, forKey: "discountPercent")
                                    itemDic.setValue(discountedPrice, forKey: "discountedPrice")
                                
                                    metaDataDic.setValue(description, forKey: "description")
                                    metaDataDic.setValue([], forKey: "images")
                                    itemDic.setValue(metaDataDic, forKey: "metaData")
                                    
                                    print(self.itemsArr)
                                if self.itemsArr.count > 0 {
                                    for items in self.itemsArr {
                                        let item = items as! NSMutableDictionary
                                        var i = -1
                                        if item.value(forKey: "productId") as! String == productId {
                                            i += 1
                                            let count = (item.value(forKey: "quantity") as! NSString).doubleValue
                                            self.itemsArr.removeObject(at: i)
                                            itemDic.setValue((quantity as NSString).doubleValue + count, forKey: "quantity")
                                            self.itemsArr.add(itemDic)
                                            break
                                        } else {
                                            self.itemsArr.add(itemDic)
                                            //break
                                        }
                                    }
                                  //  self.checkAndAddData(cartProducts[i], objToCheckFrom: cartProducts)
                                } else {
                                    self.itemsArr.add(itemDic)
                                }
                                //
                                    
                                    print(self.itemsArr)
                                
                            }
                            self.finalItemDic.setValue(self.itemsArr, forKey: "items")
                            print(cartProducts)
                            if cartProducts.count > 0 {
                                self.tableView.isHidden = false
                                self.emptyView.isHidden = true
                            } else {
                                self.tableView.isHidden = true
                                self.emptyView.isHidden = false
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            self.setPriceLbl()
                            if isLogin == "yes" {
                                self.updateCartAPI()
                            }

                        } else {
                            self.view.makeToast("Cart Updated.")
                            isLogin = "no"
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
    
//    func checkAndAddData(_ objToCheck: cartProductListStruct, objToCheckFrom: [cartProductListStruct]) {
//        //var itemStructArr = [cartProductListStruct]()
//
//        if objToCheck.productId == objToCheckFrom.value(forKey: "productId") {
//
//        } else {
//
//        }
//    }
    
    func updateCartAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            
            var  apiUrl =  BASE_URL + PROJECT_URL.USER_UPDATE_CART
            apiUrl = apiUrl + "\(String(describing: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.CART_ID)!))"
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            //print(self.makeDicForParams())
            
//            let param:[String:Any] = [ "metaData": self.finalItemDic]
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
                    self.itemsArr.removeAllObjects()
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

    func makeDicForParams() -> NSMutableDictionary {
        do {
            let notes = try self.database.prepare(self.productsTable)
            
            var metaDataDic: NSMutableDictionary = NSMutableDictionary()
            
            
            for note in notes {
                
                let prodId = note[self.prodId]
                let prodName = note[self.prodName]
                let prodDesc = note[self.prodDescription]
                let prodStock = note[self.productStock]
                let productPrice = note[self.productPrice]
                let prodCurrency = note[self.prodCurrency]
                let prodDiscountPercent = note[self.prodDiscountPercent]
                let prodDiscountPrice = note[self.prodDiscountPrice]
                let prodCount = note[self.prodCount]
                
                
                var itemDic: NSMutableDictionary = NSMutableDictionary()
                itemDic.setValue(prodId, forKey: "productId")
                itemDic.setValue("\(prodCount)", forKey: "quantity")
            
                itemDic.setValue(prodName, forKey: "name")
                itemDic.setValue("", forKey: "category")
                itemDic.setValue(prodStock, forKey: "stock")
                itemDic.setValue(prodCurrency, forKey: "currency")
                itemDic.setValue(productPrice, forKey: "price")
                itemDic.setValue(prodDiscountPercent, forKey: "discountPercent")
                itemDic.setValue(prodDiscountPrice, forKey: "discountedPrice")
            
                metaDataDic.setValue(prodDesc, forKey: "description")
                metaDataDic.setValue([], forKey: "images")
                itemDic.setValue(metaDataDic, forKey: "metaData")
                
                print(self.itemsArr)
                self.itemsArr.add(itemDic)
                print(self.itemsArr)

            }
            
            self.finalItemDic.setValue(self.itemsArr, forKey: "items")
            print(self.finalItemDic)
            
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        
        return self.finalItemDic
        
    }
    
    
    @IBAction func checkoutAction(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            self.view.makeToast("Development in Process")
        } else {
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    @IBAction func continueShoppingAction(_ sender: Any) {
    }
    
}

extension CartVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        
        let info = cartProducts[indexPath.row]
        cell.setCartData(info)
//        cell.cellTitleLbl.text = info.name
//        cell.cellPriceLbl.text = "\(info.currency) \(info.discountedPrice)"
//        cell.cellDescLbl.text = info.description
        
        return cell
    }
    
    
    
}
