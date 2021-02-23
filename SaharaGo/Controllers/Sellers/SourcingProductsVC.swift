//
//  SourcingProductsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/02/21.
//

import UIKit

class SourcingProductsVC: UIViewController {
    
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var catId: String = String()
    var categoriesProductListArr = [categoryProductListStruct]()
    var catInfo = categoryListStruct()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = UIColor.clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let country = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as? String {
           // self.getCategoriesProductsList(catId: self.catId, country: country, searchStr: "", batchSize: "10", sort: "")
            self.getCategoriesProductsList(catId: self.catId)
           // self.getCategoriesProductsList(catId: "", country: country, searchStr: "", batchSize: "10")
        }
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tableFloataction(_ sender: Any) {
        isAddProduct = "yes"
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
        vc.catId = self.catId
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        //self.getCheckCategoriesProductsList(catId: self.catInfo.id, isSubCategoryAvailable: self.catInfo.isSubCategoryAvailable, info: self.catInfo)
    }
    
    @IBAction func emptyFloatAction(_ sender: Any) {
//            isAddProduct = "yes"
//            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
//            vc.catId = self.catId
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
        
        self.openActionsheet()
        
//        self.getCheckCategoriesProductsList(catId: self.catInfo.id, isSubCategoryAvailable: self.catInfo.isSubCategoryAvailable, info: self.catInfo)
        
        }
    
    private func openActionsheet() {
        let alert = UIAlertController(title: "Select your Choice", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add Sub Category", style: .default , handler:{ (UIAlertAction)in

            isSubcategory = "yes"
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
            
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Add Product", style: .default , handler:{ (UIAlertAction)in

            isAddProduct = "yes"
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
            vc.catId = self.catId
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
//    func getCheckCategoriesProductsList(catId: String, isSubCategoryAvailable: Bool, info: categoryListStruct) {
//            if Reachability.isConnectedToNetwork() {
//                showProgressOnView(appDelegateInstance.window!)
//
//                var  apiUrl =  BASE_URL + PROJECT_URL.VENDOR_GET_CATEGORY_PRODUCTS
//                apiUrl = apiUrl + "\(catId)"
//
//                let param:[String:String] = [:]
//                ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
//                    print(json)
//                    hideAllProgressOnView(appDelegateInstance.window!)
//                    let success = json["success"].stringValue
//                    if success == "true"
//                    {
//                        self.categoriesProductListArr.removeAll()
//                        for i in 0..<json["productList"].count
//                        {
//                            let currency = json["productList"][i]["currency"].stringValue
//                            let description = json["productList"][i]["metaData"]["description"].stringValue
//                            let category = json["productList"][i]["category"].stringValue
//                            let stock = json["productList"][i]["stock"].stringValue
//                            let productId = json["productList"][i]["productId"].stringValue
//                            let itemId = json["productList"][i]["itemId"].stringValue
//                            let price = json["productList"][i]["actualPrice"].stringValue
//                            let discountedPrice = json["productList"][i]["discountedPrice"].stringValue
//                            let rating = json["productList"][i]["rating"].stringValue
//
//                            let discountPercent = json["productList"][i]["discountValue"].stringValue
//                            let name = json["productList"][i]["name"].stringValue
//
//                            var imgArr = [String]()
//                            for j in 0..<json["productList"][i]["metaData"]["images"].count {
//                                let file = json["productList"][i]["metaData"]["images"][j].stringValue
//                                imgArr.append(file)
//                            }
//
//                           // let images = json["productList"][i]["metaData"]["images"][0].stringValue
//
//                            self.categoriesProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr))
//
//                        }
//
//    //                    print(self.categoriesProductListArr)
//    //                    if self.categoriesProductListArr.count > 0 {
//    //                        self.tableView.isHidden = false
//    //                        self.emptyView.isHidden = true
//    //                    } else {
//    //                        self.tableView.isHidden = true
//    //                        self.emptyView.isHidden = false
//    //                    }
//    //                    DispatchQueue.main.async {
//    //                        self.tableView.reloadData()
//    //                    }
//
//                        if !isSubCategoryAvailable && self.categoriesProductListArr.count == 0 {
//                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerChooseSubCategoryVC") as! SellerChooseSubCategoryVC
//                            vc.catId = catId
//                            vc.selectedInfo = info
//    //                        vc.isSubCategoryAvailable = isSubCategoryAvailable
//                            vc.modalPresentationStyle = .fullScreen
//                            self.present(vc, animated: true, completion: nil)
//                        } else if isSubCategoryAvailable && self.categoriesProductListArr.count == 0 {
//
//                            isSubcategory = "no"
//                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
//
//                            categoryId = self.catInfo.id
//                            vc.modalPresentationStyle = .fullScreen
//                            self.present(vc, animated: true, completion: nil)
//
//                        } else {
//                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
//                            vc.catId = catId
//                           // vc.isSubCategoryAvailable = isSubCategoryAvailable
//                            vc.modalPresentationStyle = .fullScreen
//                            self.present(vc, animated: true, completion: nil)
//                        }
//
//                    }
//                    else {
//                        self.view.makeToast("\(json["message"].stringValue)")
//                        //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
//                    }
//                }, errorBlock: { (NSError) in
//                    UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
//                    hideAllProgressOnView(appDelegateInstance.window!)
//                })
//
//            }else{
//                hideAllProgressOnView(appDelegateInstance.window!)
//                UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
//            }
//        }
    
    
//    func getCategoriesProductsList(catId: String, country: String, searchStr: String, batchSize: String, sort: String) {
//        if Reachability.isConnectedToNetwork() {
//            showProgressOnView(appDelegateInstance.window!)
//            //{country}/{pageNumber}/{limit}?categoryId=&search=&sort=
////            var  apiUrl =  BASE_URL + PROJECT_URL.USER_GET_PRODUCTS
//            var apiUrl = BASE_URL + PROJECT_URL.VENDOR_GET_CATEGORY_PRODUCTS
//            apiUrl = apiUrl + "\(country)/" + "1/" + "\(batchSize)" + "?categoryId=\(catId)" + "&search=\(searchStr)" + "&sort=\(sort)"
//
//            let url : NSString = apiUrl as NSString
//            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
//
//
//            // api/v1/user/getProducts/{country}/{pageNumber}/{limit}?categoryId=&search=&sort=
//            let param:[String:String] = [:]
//            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
//                print(json)
//                hideAllProgressOnView(appDelegateInstance.window!)
//                let success = json["success"].stringValue
//                if success == "true"
//                {
//                    self.categoriesProductListArr.removeAll()
//                    for i in 0..<json["productList"].count
//                    {
//                        let currency = json["productList"][i]["currency"].stringValue
//                        let description = json["productList"][i]["metaData"]["description"].stringValue
//                        let category = json["productList"][i]["category"].stringValue
//                        let stock = json["productList"][i]["stock"].stringValue
//                        let actualPrice = json["productList"][i]["actualPrice"].stringValue
//                        let productId = json["productList"][i]["productId"].stringValue
//                        let itemId = json["productList"][i]["itemId"].stringValue
//                        let price = json["productList"][i]["price"].stringValue
//                        let discountedPrice = json["productList"][i]["discountedPrice"].stringValue
//                        let rating = json["productList"][i]["rating"].stringValue
//
//                        let discountPercent = json["productList"][i]["discountValue"].stringValue
//                        let name = json["productList"][i]["name"].stringValue
//
//
//                        var imgArr = [String]()
//                        for j in 0..<json["productList"][i]["metaData"]["images"].count {
//
//                            let file = json["productList"][i]["metaData"]["images"][j].stringValue
//                            imgArr.append(file)
//                        }
//
//                        //let images = json["productList"][i]["metaData"]["images"][0].stringValue
//
//                        self.categoriesProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr, actualPrice: actualPrice))
//
//                    }
//
//                    print(self.categoriesProductListArr)
//                    if self.categoriesProductListArr.count > 0 {
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
//
//                }
//                else {
//                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
//                }
//            }, errorBlock: { (NSError) in
//                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
//                hideAllProgressOnView(appDelegateInstance.window!)
//            })
//
//        }else{
//            hideAllProgressOnView(appDelegateInstance.window!)
//            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
//        }
//    }
    
    func getCategoriesProductsList(catId: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            var  apiUrl =  BASE_URL + PROJECT_URL.VENDOR_GET_CATEGORY_PRODUCTS
            apiUrl = apiUrl + "\(catId)"
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.categoriesProductListArr.removeAll()
                    for i in 0..<json["productList"].count
                    {
                        let currency = json["productList"][i]["currency"].stringValue
                        let description = json["productList"][i]["metaData"]["description"].stringValue
                        let category = json["productList"][i]["category"].stringValue
                        let stock = json["productList"][i]["stock"].stringValue
                        let productId = json["productList"][i]["productId"].stringValue
                        let itemId = json["productList"][i]["itemId"].stringValue
                        let price = json["productList"][i]["actualPrice"].stringValue
                        let discountedPrice = json["productList"][i]["discountedPrice"].stringValue
                        let rating = json["productList"][i]["rating"].stringValue
                        
                        let discountPercent = json["productList"][i]["discountValue"].stringValue
                        let name = json["productList"][i]["name"].stringValue
                        //let images = json["productList"][i]["metaData"]["images"][0].stringValue
                        
                        var imgArr = [String]()
                        for j in 0..<json["productList"][i]["metaData"]["images"].count {
                            let file = json["productList"][i]["metaData"]["images"][j].stringValue
                            imgArr.append(file)
                        }
                        
                        
                        self.categoriesProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr))

                    }
                    
                    
                    print(self.categoriesProductListArr)
                    if self.categoriesProductListArr.count > 0 {
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
                    self.view.makeToast("\(json["message"].stringValue)")
                    //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
    
    func deleteProductAPI(_ id: String) {
            if Reachability.isConnectedToNetwork() {
                showProgressOnView(appDelegateInstance.window!)
                
                let fullUrl = BASE_URL + PROJECT_URL.VENDOR_DELETE_PRODUCT + id
                let param:[String:String] = [:]
                
                ServerClass.sharedInstance.deleteRequestWithUrlParameters(param, path: fullUrl, successBlock: {  (json) in
                    print(json)
                    hideAllProgressOnView(appDelegateInstance.window!)
                    let success = json["success"].stringValue
                    
                    if success  == "true"
                    {
                        self.view.makeToast(json["message"].stringValue)
                        self.getCategoriesProductsList(catId: self.catId)
                       // self.getCategoriesProductsList(catId: self.catId, country: country, searchStr: "", batchSize: "10", sort: "")
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

extension SourcingProductsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.categoriesProductListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let nib = UINib(nibName: "SellerProductsCell", bundle: nil)
        let cell = nib.instantiate(withOwner: self, options: nil).last as! SellerProductsCell
        
        let info =  self.categoriesProductListArr[indexPath.row]
        print(info)
        cell.cellTitleLbl.text = info.name
        cell.cellDiscountPercentLbl.text = "\(info.discountPercent)% OFF"
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(info.currency) \(info.price)")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        cell.cellOldPrice.attributedText = attributeString
        cell.cellNewPrice.text = "\(info.currency) \(info.discountedPrice)"
        cell.cellStockLbl.text = "Stock: \(info.stock)"
        
        cell.cellEditBtn.tag = indexPath.row
        cell.cellEditBtn.addTarget(self, action: #selector(self.editBtnAction(_:)), for: .touchUpInside)
        cell.cellDeleteBtn.tag = indexPath.row
        cell.cellDeleteBtn.addTarget(self, action: #selector(self.deleteBtnAction(_:)), for: .touchUpInside)
        if info.images!.count > 0 {
            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.images![0])"), placeholderImage: UIImage(named: "edit cat_img"))
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let info =  categoriesList[indexPath.row]
//        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerCatProductsVC") as! SellerCatProductsVC
//        vc.catId = info.id
//        vc.headerTitleLbl = info.name
//        vc.categoryInfo = info
//
//        if info.isSubCategoryAvailable {
//            isSubcategory = "yes"
//        } else {
//            isSubcategory = "no"
//        }
//
//        categoryId = info.id
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func editBtnAction(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = [categoriesProductListArr[sender.tag]]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
        vc.selectedProductsInfo = selectedInfo
        vc.isHomeProducts = "yes"
        vc.catId = self.catId
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteBtnAction(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = [categoriesProductListArr[sender.tag]]
        print(selectedInfo)
        self.deleteProductAPI(selectedInfo[0].itemId)
        
    }
    
}
