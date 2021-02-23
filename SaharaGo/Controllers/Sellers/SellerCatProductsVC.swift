//
//  SellerCatProductsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 15/12/20.
//

import UIKit

class SellerCatProductsVC: UIViewController {
    
    var catId: String = String()
    var testArr = [String]()
    
    @IBOutlet var floatBtn: UIButton!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var headerTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var categoriesProductListArr = [categoryProductListStruct]()
    var categoriesList = [categoryListStruct]()
    var categoryInfo = categoryListStruct()
    var headerTitleLbl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.register(UINib(nibName: "ProductsCategoriesCell", bundle: Bundle.main), forCellReuseIdentifier: "ProductsCategoriesCell")
        tableView.delegate = self
        tableView.dataSource = self
        
       // NotificationCenter.default.addObserver(self, selector: #selector(updateCatProducts), name: Notification.Name("updateCatProducts"), object: nil)
        
        self.headerTitle.text = self.headerTitleLbl
        
        if isSubcategory == "yes" {
            self.getSubCategoriesofCategoryAPI()
            self.floatBtn.isHidden = false
        } else {
//            categoryId = self.categoryInfo.id
//            self.getCategoriesProductsList(catId: self.categoryInfo.id, isSubCategoryAvailable: self.categoryInfo.isSubCategoryAvailable, info: self.categoryInfo)
            self.getCategoriesProductsList(catId: self.catId)
            self.floatBtn.isHidden = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
//    @objc func updateCatProducts() {
//        self.getCategoriesProductsList(catId: categoryId)
//    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerNotificationVC") as! SellerNotificationVC
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
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
    
    func getSubCategoriesofCategoryAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            var  apiUrl =  BASE_URL + PROJECT_URL.VENDOR_GET_SUBCATEGORY
            apiUrl = apiUrl + "\(catId)"
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.categoriesList.removeAll()
                    for i in 0..<json["categoryList"].count
                    {
                        let id = json["categoryList"][i]["id"].stringValue
                        
                        let status = json["categoryList"][i]["status"].stringValue
                        let name = json["categoryList"][i]["name"].stringValue
                        let isSubCategoryAvailable = json["categoryList"][i]["isSubCategoryAvailable"].boolValue
                        
                        let parentCategory = json["categoryList"][i]["parentCategory"].stringValue
                        
                       // let metadata = json["categoryList"][i]["metaData"]
                        
                        let description = json["categoryList"][i]["metaData"]["description"].stringValue
                        let image = json["categoryList"][i]["metaData"]["image"].stringValue
                        
                        
                        self.categoriesList.append(categoryListStruct.init(id: id, status: status, name: name, description: description, image: image, isSubCategoryAvailable: isSubCategoryAvailable, parentCategory: parentCategory ))
                    }
                    
                    if self.categoriesList.count > 0 {
                        self.tableView.isHidden = false
                        self.emptyView.isHidden = true
                    } else {
                        self.tableView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    print(self.categoriesList)
                    
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
    
    func getCategoriesProductsList(catId: String, isSubCategoryAvailable: Bool, info: categoryListStruct) {
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
                            
                            var imgArr = [String]()
                            for j in 0..<json["productList"][i]["metaData"]["images"].count {
                                let file = json["productList"][i]["metaData"]["images"][j].stringValue
                                imgArr.append(file)
                            }
                            
                           // let images = json["productList"][i]["metaData"]["images"][0].stringValue
                            
                            self.categoriesProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr))

                        }
                        
    //                    print(self.categoriesProductListArr)
    //                    if self.categoriesProductListArr.count > 0 {
    //                        self.tableView.isHidden = false
    //                        self.emptyView.isHidden = true
    //                    } else {
    //                        self.tableView.isHidden = true
    //                        self.emptyView.isHidden = false
    //                    }
    //                    DispatchQueue.main.async {
    //                        self.tableView.reloadData()
    //                    }
                        
                        if !isSubCategoryAvailable && self.categoriesProductListArr.count == 0 {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerChooseSubCategoryVC") as! SellerChooseSubCategoryVC
                            vc.catId = catId
                            vc.selectedInfo = info
    //                        vc.isSubCategoryAvailable = isSubCategoryAvailable
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        } else if isSubCategoryAvailable && self.categoriesProductListArr.count == 0 {
                            
                            isSubcategory = "no"
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC

                            categoryId = self.categoryInfo.id
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                            
                        } else {
                            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
                            vc.catId = catId
                           // vc.isSubCategoryAvailable = isSubCategoryAvailable
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
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
    
    @IBAction func floatBtnAction(_ sender: Any) {
        
        //categoryId = selectedInfo.id
        
        self.getCategoriesProductsList(catId: self.categoryInfo.id, isSubCategoryAvailable: self.categoryInfo.isSubCategoryAvailable, info: self.categoryInfo)
        
//        if self.categoriesProductListArr.count > 0 && !self.categoryInfo.isSubCategoryAvailable {
//
//            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
//            vc.catId = self.categoryInfo.id
//            // vc.isSubCategoryAvailable = isSubCategoryAvailable
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
//        } else if self.categoriesProductListArr.count == 0 && !self.categoryInfo.isSubCategoryAvailable {
//            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerChooseSubCategoryVC") as! SellerChooseSubCategoryVC
//            vc.catId = self.categoryInfo.id
//            vc.selectedInfo = self.categoryInfo
//            //                        vc.isSubCategoryAvailable = isSubCategoryAvailable
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
//        } else {
//            isSubcategory = "no"
//            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
//
//            categoryId = self.categoryInfo.id
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true, completion: nil)
//        }
        
    }
    
    
}

extension SellerCatProductsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSubcategory == "yes" {
            return 110.0
        } else {
            return 120.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSubcategory == "yes" {
            return self.categoriesList.count
        } else {
            return self.categoriesProductListArr.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isSubcategory == "yes" {
            let nib = UINib(nibName: "ProductsCategoriesCell", bundle: nil)
            let cell = nib.instantiate(withOwner: self, options: nil).last as! ProductsCategoriesCell

            let info =  categoriesList[indexPath.row]
            cell.cellLbl.text = info.name
            cell.cellSublbl.text = info.description
            //            self.setCellData(cell: cell, info: info, index: indexPath.row)
            if info.isSubCategoryAvailable {
                cell.cellBtn.isHidden = true
            } else {
                cell.cellBtn.isHidden = false
            }
            cell.cellBtn.tag = indexPath.row
            cell.cellBtn.addTarget(self, action: #selector(self.bookbtn1(_:)), for: .touchUpInside)
            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SellerCatProductsCell", for: indexPath) as! SellerCatProductsCell
            
            let info =  categoriesProductListArr[indexPath.row]
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
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            if !(cell.reuseIdentifier != nil) {
                let info =  categoriesList[indexPath.row]
                let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
                let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerCatProductsVC") as! SellerCatProductsVC
                vc.catId = info.id
                vc.headerTitleLbl = info.name
                vc.categoryInfo = info
                if info.isSubCategoryAvailable {
                    isSubcategory = "yes"
                } else {
                    isSubcategory = "no"
                }
                
                categoryId = info.id
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }

        }
        
        if isSubcategory == "yes" {
            let info =  categoriesList[indexPath.row]
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerCatProductsVC") as! SellerCatProductsVC
            vc.catId = info.id
            vc.headerTitleLbl = info.name
            vc.categoryInfo = info
            if info.isSubCategoryAvailable {
                isSubcategory = "yes"
            } else {
                isSubcategory = "no"
            }
            
            categoryId = info.id
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @objc func editBtnAction(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = [categoriesProductListArr[sender.tag]]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
        vc.selectedProductsInfo = selectedInfo
        vc.catId = self.catId
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteBtnAction(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = [categoriesProductListArr[sender.tag]]
        self.deleteProductAPI(selectedInfo[0].itemId)

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
    
    @objc func bookbtn1(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = categoriesList[sender.tag]
        categoryId = selectedInfo.id
        
        self.getCategoriesProductsList(catId: selectedInfo.id, isSubCategoryAvailable: selectedInfo.isSubCategoryAvailable, info: selectedInfo)
    }
}
