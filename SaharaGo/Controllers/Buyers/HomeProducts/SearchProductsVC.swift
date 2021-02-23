//
//  SearchProductsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 16/01/21.
//

import UIKit

class SearchProductsVC: UIViewController, UISearchBarDelegate {
    
    var searchProductListArr = [categoryProductListStruct]()
    
    var testArr = [String]()
    var apiTotalCount: Int = Int()
    var pageNumber = 1
    var isPagination = false

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBar.delegate = self
        
        
        self.searchBar.becomeFirstResponder()
        
        if let country = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as? String {
            //self.searchProductListArr.removeAll()
            //self.isPagination = true
            self.getCategoriesProductsList(catId: "", country: country, searchStr: "", pageNo: self.pageNumber, sort: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        searchBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
    }
        
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterAction(_ sender: Any) {
        let alert = UIAlertController(title: "Sort By", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Price (High to Low)", style: .default , handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: "", country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", pageNo: 1, sort: "Price_H_L")
        }))
        
        alert.addAction(UIAlertAction(title: "Price (Low to High)", style: .default , handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: "", country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", pageNo: 1, sort: "Price_L_H")
            
        }))

        alert.addAction(UIAlertAction(title: "Rating", style: .default , handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: "", country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", pageNo: 1, sort: "Rating")
        }))
        
        alert.addAction(UIAlertAction(title: "New Arrivals", style: .default, handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: "", country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", pageNo: 1, sort: "New_Arrival")
        }))
        
        alert.addAction(UIAlertAction(title: "Top Deals", style: .default, handler:{ (UIAlertAction)in
            self.getCategoriesProductsList(catId: "", country: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as! String, searchStr: "", pageNo: 1, sort: "Top_Deals")
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: nil)
    }
    
    
    func getCategoriesProductsList(catId: String, country: String, searchStr: String, pageNo: Int, sort: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            //{country}/{pageNumber}/{limit}?categoryId=&search=&sort=
            var  apiUrl =  BASE_URL + PROJECT_URL.USER_GET_PRODUCTS
            apiUrl = apiUrl + "\(country)/" + "\(pageNo)/" + "100" + "?categoryId=\(catId)" + "&search=\(searchStr)" + "&sort=\(sort)"
            
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            
            // api/v1/user/getProducts/{country}/{pageNumber}/{limit}?categoryId=&search=&sort=
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                self.apiTotalCount = json["count"].intValue
                if success == "true"
                {
                    if !self.isPagination {
                        self.searchProductListArr.removeAll()
                    }
                    
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
                        
                        searchProductListArrCopy = self.searchProductListArr
                        
                    }
                    
                    print(self.searchProductListArr)
                    self.isPagination = false
                    if self.searchProductListArr.count > 0 {
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
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.getCategoriesProductsList(catId: "", country: country, searchStr: "", pageNo: 1, sort: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            //self.searchProductListArr = self.searchProductListArrCopy
            if let country = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as? String {
                self.isPagination = false
                self.getCategoriesProductsList(catId: "", country: country, searchStr: "", pageNo: 1, sort: "")
            }
        } else {
            if let country = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as? String {
                self.isPagination = false
                self.getCategoriesProductsList(catId: "", country: country, searchStr: searchText, pageNo: 1, sort: "")
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    
}

extension SearchProductsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchProductListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsCell", for: indexPath) as! ProductsCell
        
        let info =  searchProductListArr[indexPath.row]
        cell.cellTitleLbl.text = info.name
        cell.cellStockLbl.text = "Stock: \(info.stock)"
        cell.cellDiscountLbl.text = "\(info.discountPercent)% OFF"
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(info.currency) \(info.actualPrice)")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        cell.cellOldPrice.attributedText = attributeString
        cell.cellNewPrice.text = "\(info.currency) \(info.discountedPrice)"
        if info.images!.count > 0 {
            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.images![0])"), placeholderImage: UIImage(named: "edit cat_img"))
        } else {
            cell.cellImg.image = UIImage(named: "edit cat_img")
        }
        
        cell.cellBtn.tag = indexPath.row
        //cell.cellBtn.addTarget(self, action: #selector(self.wishlistAction(_:)), for: .touchUpInside)
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let info =  searchProductListArr[indexPath.row]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.productDetails = info
        vc.productImgArr = info.images!
        vc.itemID = info.itemId
        //vc.productImgStr = info.images
        self.navigationController?.pushViewController(vc, animated: true)

        
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        if indexPath.row == searchProductListArr.count - 3 && self.apiTotalCount > self.searchProductListArr.count {
//
//            if let country = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as? String {
//                self.pageNumber += 1
//                self.isPagination = true
//                self.getCategoriesProductsList(catId: "", country: country, searchStr: "", pageNo: self.pageNumber)
//
//            }
//
//        }
//
//
//    }
    
    
}
