//
//  ProductsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 08/12/20.
//

import UIKit

class ProductsVC: UIViewController {
    
    var catId: String = String()
    var categoriesProductListArr = [categoryProductListStruct]()
    var testArr = [String]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        if let country = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as? String {
            self.getCategoriesProductsList(catId: self.catId, country: country, searchStr: "", batchSize: "100", sort: "")
           // self.getCategoriesProductsList(catId: "", country: country, searchStr: "", batchSize: "10")
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "filter"), style: .plain, target: self, action: #selector(filterTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        
    }
    
    @objc func filterTapped() {
        let alert = UIAlertController(title: "Sort By", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Price (High to Low)", style: .default , handler:{ (UIAlertAction)in
            //Price_H_L
            self.getCategoriesProductsList(catId: self.catId, country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", batchSize: "100", sort: "Price_H_L")
        }))
        
        alert.addAction(UIAlertAction(title: "Price (Low to High)", style: .default , handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: self.catId, country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", batchSize: "100", sort: "Price_L_H")
            
        }))

        alert.addAction(UIAlertAction(title: "Rating", style: .default , handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: self.catId, country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", batchSize: "100", sort: "Rating")
        }))
        
        alert.addAction(UIAlertAction(title: "New Arrivals", style: .default, handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: self.catId, country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", batchSize: "100", sort: "New_Arrival")
        }))
        
        alert.addAction(UIAlertAction(title: "Top Deals", style: .default, handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: self.catId, country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", batchSize: "100", sort: "Top_Deals")
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: nil)
    }
    
    func getCategoriesProductsList(catId: String, country: String, searchStr: String, batchSize: String, sort: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            //{country}/{pageNumber}/{limit}?categoryId=&search=&sort=
            var  apiUrl =  BASE_URL + PROJECT_URL.USER_GET_PRODUCTS
            apiUrl = apiUrl + "\(country)/" + "1/" + "\(batchSize)" + "?categoryId=\(catId)" + "&search=\(searchStr)" + "&sort=\(sort)"
            
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
                    self.categoriesProductListArr.removeAll()
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
                        
                        let discountPercent = json["productList"][i]["discountValue"].stringValue
                        let name = json["productList"][i]["name"].stringValue
                        
                        
                        var imgArr = [String]()
                        for j in 0..<json["productList"][i]["metaData"]["images"].count {
                            
                            let file = json["productList"][i]["metaData"]["images"][j].stringValue
                            imgArr.append(file)
                        }
                        
                        //let images = json["productList"][i]["metaData"]["images"][0].stringValue
                        
                        self.categoriesProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, itemId: itemId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name, images: imgArr, actualPrice: actualPrice))
                        
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

extension ProductsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.categoriesProductListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsCell", for: indexPath) as! ProductsCell
        
        let info =  categoriesProductListArr[indexPath.row]
        cell.cellTitleLbl.text = info.name
        cell.cellStockLbl.text = "Stock: \(info.stock)"
        cell.cellDiscountLbl.text = "\(info.discountPercent)% OFF"
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(info.currency) \(info.actualPrice)")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        cell.cellOldPrice.attributedText = attributeString
        cell.cellNewPrice.text = "\(info.currency) \(info.discountedPrice)"
//        if self.testArr.count > 0 {
//            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.images![0])"), placeholderImage: UIImage(named: "edit cat_img"))
//        }
        if info.images!.count > 0 {
            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.images![0])"), placeholderImage: UIImage(named: "edit cat_img"))
        }
        
        
        cell.cellBtn.tag = indexPath.row
        cell.cellBtn.addTarget(self, action: #selector(self.wishlistAction(_:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let info =  categoriesProductListArr[indexPath.row]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.productDetails = info
        //vc.productImgStr = info.images
        vc.productImgArr = info.images!
        vc.itemID = info.itemId
        self.navigationController?.pushViewController(vc, animated: true)
        //            vc.modalPresentationStyle = .fullScreen
        //            self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func wishlistAction(_ sender : UIButton){
        // call your segue code here
        //            let selectedInfo = categoriesProductListArr[sender.tag]
        //            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        //            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
        //            vc.catId = selectedInfo.id
        //            vc.modalPresentationStyle = .fullScreen
        //            self.present(vc, animated: true, completion: nil)
    }
}
