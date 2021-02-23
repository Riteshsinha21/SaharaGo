//
//  SellerProductsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 15/12/20.
//

import UIKit
import Floaty

class SellerProductsVC: UIViewController {
    
    @IBOutlet var emptyFloatBtn: UIButton!
    @IBOutlet var floatBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var floatBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet var emptyFloatBottomConstraint: NSLayoutConstraint!
    
    var categoriesList = [categoryListStruct]()
    var categoriesProductListArr = [categoryProductListStruct]()
    var allProductListArr = [categoryProductListStruct]()
    var testArr = [String]()
    let btn = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //        tableView.register(UINib(nibName: "ProductsCategoriesCell", bundle: Bundle.main), forCellReuseIdentifier: "ProductsCategoriesCell")
        tableView.register(UINib(nibName: "SellerProductsCell", bundle: Bundle.main), forCellReuseIdentifier: "SellerProductsCell")
        
        
        tableView.estimatedRowHeight = 250
        //tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        self.floatBtnBottomConstraint.constant += tabBarController!.tabBar.frame.size.height
        self.emptyFloatBottomConstraint.constant += tabBarController!.tabBar.frame.size.height
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //        let floaty = Floaty()
        //        floaty.addItem(title: "Hello, World!")
        //        floaty.paddingY += tabBarController!.tabBar.frame.size.height
        //        self.view.addSubview(floaty)
        
        
        self.backBtn.isHidden = true
        //        self.getCategoriesList()
        self.getAllProductsList()
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
    
    @IBAction func backAction(_ sender: Any) {
    }
    
    func getCategoriesList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_GET_ALL_CATEGORY, successBlock: { (json) in
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
    
    func getAllProductsList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_GET_ALL_PRODUCTS, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.allProductListArr.removeAll()
                    for i in 0..<json["productList"].count
                    {
                        let currency = json["productList"][i]["currency"].stringValue
                        let categoryId = json["productList"][i]["categoryId"].stringValue
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
                        
                        
                        self.allProductListArr.append(categoryProductListStruct.init(categoryId: categoryId, currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr))
                        
                    }
                    
                    if self.allProductListArr.count > 0 {
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
                        
                        self.categoriesProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr))
                        
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
    
    //    func floatingButton(){
    //
    //        btn.frame = CGRect(x: 285, y: 485, width: 100, height: 100)
    //        btn.setTitle("All Defects", for: .normal)
    //        btn.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    //        btn.clipsToBounds = true
    //        btn.layer.cornerRadius = 50
    //        btn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    //        btn.layer.borderWidth = 3.0
    //        btn.addTarget(self,action: #selector(floatTapped), for: .touchUpInside)
    //        self.tableView.addSubview(btn)
    ////        view.addSubview(btn)
    //    }
    
    //    @objc func floatTapped() {
    //        print("jiyooo")
    //    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    ////           let  off = scrollView.contentOffset.y
    //            let  off = self.tableView.contentOffset.y
    //
    //           btn.frame = CGRect(x: 285, y:   off + 485, width: btn.frame.size.width, height: btn.frame.size.height)
    //    }
    
    
    @IBAction func floatAction(_ sender: Any) {
//        isSubcategory = "no"
//        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
//        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
//
//        categoryId = "0"
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
        
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SourcingVC") as! SourcingVC
        
        categoryId = "0"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
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
//                    self.getCategoriesProductsList(catId: self.catId)
                    self.getAllProductsList()
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

extension SellerProductsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.allProductListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let nib = UINib(nibName: "SellerProductsCell", bundle: nil)
        let cell = nib.instantiate(withOwner: self, options: nil).last as! SellerProductsCell
        
        let info =  allProductListArr[indexPath.row]
        
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
        
        
        //            cell.cellLbl.text = info.name
        //            cell.cellSublbl.text = info.description
        //            if info.isSubCategoryAvailable {
        //                cell.cellBtn.isHidden = true
        //            } else {
        //                cell.cellBtn.isHidden = false
        //            }
        //            cell.cellBtn.tag = indexPath.row
        //            cell.cellBtn.addTarget(self, action: #selector(self.bookbtn1(_:)), for: .touchUpInside)
        //            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
        
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
    
    @objc func bookbtn1(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = categoriesList[sender.tag]
        categoryId = selectedInfo.id
        
        //            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        //            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
        //            vc.catId = selectedInfo.id
        //
        //            vc.modalPresentationStyle = .fullScreen
        //            self.present(vc, animated: true, completion: nil)
        
        self.getCategoriesProductsList(catId: selectedInfo.id, isSubCategoryAvailable: selectedInfo.isSubCategoryAvailable, info: selectedInfo)
    }
    
    @objc func editBtnAction(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = [allProductListArr[sender.tag]]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
        vc.selectedProductsInfo = selectedInfo
        vc.isHomeProducts = "yes"
        vc.catId = selectedInfo[0].categoryId
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteBtnAction(_ sender : UIButton){
        // call your segue code here
        let selectedInfo = [allProductListArr[sender.tag]]
        print(selectedInfo)
        self.deleteProductAPI(selectedInfo[0].itemId)
        
    }
    
}
