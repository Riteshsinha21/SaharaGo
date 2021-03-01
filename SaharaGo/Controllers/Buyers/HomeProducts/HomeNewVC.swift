//
//  HomeNewVC.swift
//  SaharaGo
//
//  Created by Ritesh on 18/12/20.
//

import UIKit
import SQLite

struct topDeals_Struct {
    var currency:String = ""
    var productId:String = ""
    var name:String = ""
    var description:String = ""
    var dimension :String = ""
    var wishlisted:Bool = false
    var discountType :String = ""
    var itemId :String = ""
    var categoryId :String = ""
    //    var actualPrice :Int = 0
    //    var discountValue :Int = 0
    //    var stock :Int = 0
    //    var discountedPrice :Int = 0
    //    var rating :Int = 0
    var actualPrice :String = ""
    var discountValue :String = ""
    var stock :String = ""
    var discountedPrice :String = ""
    var rating :String = ""
    var images: [String]?
}

class HomeNewVC: SuperViewController {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var cartBadgeLbl: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var topDelasEmptyView: UIView!
    @IBOutlet var newArrivalEmptyView: UIView!
    @IBOutlet var categoriesCollView: UICollectionView!
    @IBOutlet var bannerCollView: UICollectionView!
    @IBOutlet var pagecontrol: UIPageControl!
    @IBOutlet var labelCollectionView: UICollectionView!
    @IBOutlet weak var newArrivalCollView: UICollectionView!
    @IBOutlet weak var countryButton: UIButton!
    //    var topDealsProductList = [TopDealsProductList]()
    //    var newArrivalsProductList = [TopDealsProductList]()
    var topDealsProductList = [topDeals_Struct]()
    var newArrivalsProductList = [topDeals_Struct]()
    var labelArr = ["Milled Grain", "Vegetable Oil", "Footwear", "Jewelery", "Home Appliances", "Dairy products", "Health", "Medicines", "Mens Wear"]
    
    //    var imageArr = [#imageLiteral(resourceName: "bennin_banner"), #imageLiteral(resourceName: "bennin_banner"), #imageLiteral(resourceName: "bennin_banner"), #imageLiteral(resourceName: "bennin_banner")]
    
    // var imageArr = ["bennin_banner", "footwears_cover", "upto", "Agricultural  crops"]
    var bannersArr = [String]()
    var imageArr = ["Agricultural  crops", "Agricultural  crops", "Agricultural  crops", "Agricultural  crops"]
    
    var currentCellIndex = 0
    var timer:Timer?
    
    @IBOutlet weak var newArrivalCollHeight: NSLayoutConstraint!
    
    var database : Connection!
    let productsTable = Table("products")
    let id = Expression<Int>("id")
    let prodId = Expression<String>("prodId")
    let itemId = Expression<String>("itemId")
    let prodName = Expression<String>("prodName")
    let prodDescription = Expression<String>("prodDescription")
    let productStock = Expression<String>("prodStock")
    let productPrice = Expression<String>("prodPrice")
    let prodCurrency = Expression<String>("prodCurrency")
    let prodDiscountPercent = Expression<String>("prodDiscountPercent")
    let prodDiscountPrice = Expression<String>("prodDiscountPrice")
    let prodCount = Expression<Int>("prodCount")
    let images = Expression<String>("images")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge(_:)), name: Notification.Name("updateCartBadge"), object: nil)
        
        self.cartBadgeLbl.isHidden = true
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                self.cartBadgeLbl.isHidden = true
            } else {
                self.cartBadgeLbl.isHidden = false
                self.cartBadgeLbl.text = "\(cartCount)"
            }
            
        }
        
    }
    
    @objc func updateCartBadge(_ notification: Notification) {
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                self.cartBadgeLbl.isHidden = true
            } else {
                self.cartBadgeLbl.isHidden = false
                let cartCountDic = notification.userInfo?["userInfo"] as? [String: Any] ?? [:]
                self.cartBadgeLbl.text = "\(String(describing: cartCountDic["cartCount"]!))"
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.cartBadgeLbl.layer.cornerRadius = 10
        self.navigationController?.navigationBar.isHidden = false
        
        // navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "bag"), style: .plain, target: self, action: #selector(cartTapped))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "country"), style: .plain, target: self, action: #selector(countryTapped))
        isHome = "no"
        self.tabBarController?.tabBar.isHidden = false
        self.makeNavCartBtn()
        self.getCategoriesList()
        if let country = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY) as? String {
            getBanners()
            getTopDeals(country)
            getNewArrivals(country)
        }
        
        if let flag = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_FLAG) as? String {
            let imageUrl = FLAG_BASE_URL + "/" + flag
            self.countryButton.sd_setImage(with: URL(string: imageUrl), for: .normal)
        }
        
        guard let countryColorStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.COUNTRY_COLOR_CODE) as? String else {return}
        guard let rgba = countryColorStr.slice(from: "(", to: ")") else { return }
        let myStringArr = rgba.components(separatedBy: ",")
        self.tabBarController?.tabBar.tintColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        self.navigationController?.navigationBar.barTintColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
//        self.addNavBarImage()
        //self.makeNavCartBtn()
        self.addCartBtns()
        self.setUpUI()
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "SaharaGo new logo-1"))
        //self.headerView.backgroundColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
    }
    
    func setUpUI() {
       // let logoImage = UIImage.init(named: "SaharaGo new logo-1")
        let logoImage = UIImage.init(named: "logo")
        let logoImageView = UIImageView.init(image: logoImage)
        //CGRectMake(-40, 0, 150, 25)
       // logoImageView.frame = CGRect(x: -10, y: 0, width: 150, height: 25)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = 0
        navigationItem.leftBarButtonItems = [imageItem]
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
                
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: filterBtn)]
            }
        }
        
    }
    
    func addCartBtns() {

        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
        if cartCount == 0 {
            
            let search = UIBarButtonItem(image: UIImage(named: "search-1"), style: .plain, target: self, action: #selector(searchTapped))
            let notification = UIBarButtonItem(image: UIImage(named: "noti"), style: .plain, target: self, action: #selector(notificationTapped))
            let wishlist = UIBarButtonItem(image: UIImage(named: "wishlist-2"), style: .plain, target: self, action: #selector(wishlistTapped))
            let cart = UIBarButtonItem(image: UIImage(named: "bag"), style: .plain, target: self, action: #selector(cartTapped))
            
            self.navigationItem.rightBarButtonItems = [cart, wishlist, notification, search]
            
        } else {
            
            let search = UIBarButtonItem(image: UIImage(named: "search-1"), style: .plain, target: self, action: #selector(searchTapped))
            let notification = UIBarButtonItem(image: UIImage(named: "noti"), style: .plain, target: self, action: #selector(notificationTapped))
            let wishlist = UIBarButtonItem(image: UIImage(named: "wishlist-2"), style: .plain, target: self, action: #selector(wishlistTapped))
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
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: filterBtn), wishlist, notification, search]
            }
        
        }
        
        
    }
    
    
    func addNavBarImage() {

        let navController = navigationController!

        let image = UIImage(named: "SaharaGo new logo-1") //Your logo url here
        let imageView = UIImageView(image: image)

        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height

        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2

        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit

        navigationItem.titleView = imageView
    }
    
    @objc func countryTapped() {
        
    }
    
    @objc func cartTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func searchTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SearchProductsVC") as! SearchProductsVC
        //vc.catId = info.id
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func wishlistTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "WishlistVC") as! WishlistVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func notificationTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        self.navigationController?.pushViewController(vc, animated: true)
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
            table.column(self.prodId)
            table.column(self.itemId)
            table.column(self.prodCount)
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
    
    //    func getTopDeals(_ country: String){
    //
    //        if Reachability.isConnectedToNetwork(){
    //
    //            showProgressOnView(appDelegateInstance.window!)
    //
    //            let apiUrl = BASE_URL + PROJECT_URL.TOP_DEALS + country
    //
    //            let url : NSString = apiUrl as NSString
    //            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
    //
    //            ServerClass.sharedInstance.getRequestWithUrlParameters([:], path: urlStr as String, successBlock: { (response) in
    //
    //                print(response)
    //                let jsonData = try! response.rawData()
    //                let jsonDecoder = JSONDecoder()
    //                do{
    //                    self.topDealsProductList.removeAll()
    //                    let topDealsResponse = try jsonDecoder.decode(TopDeals.self, from: jsonData)
    //                    topDealsResponse.productList?.forEach({ (product) in
    //                        self.topDealsProductList.append(product)
    //                    })
    //
    //                    if self.topDealsProductList.count > 0 {
    //                        self.categoriesCollView.isHidden = false
    //                        self.topDelasEmptyView.isHidden = true
    //                    } else {
    //                        self.categoriesCollView.isHidden = true
    //                        self.topDelasEmptyView.isHidden = false
    //                    }
    //
    //                    DispatchQueue.main.async {
    //                        self.categoriesCollView.reloadData()
    //                        hideAllProgressOnView(appDelegateInstance.window!)
    //                    }
    //                }catch let error{
    //                    hideAllProgressOnView(appDelegateInstance.window!)
    //                    print(error.localizedDescription)
    //                }
    //
    //
    //            }) { (error) in
    //                hideAllProgressOnView(appDelegateInstance.window!)
    //                print(error.localizedDescription)
    //            }
    //        }
    //
    //    }
    
    func getTopDeals(_ country: String){
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            
            let apiUrl = BASE_URL + PROJECT_URL.TOP_DEALS + country
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.topDealsProductList.removeAll()
                    for i in 0..<json["productList"].count
                    {
                        let currency = json["productList"][i]["currency"].stringValue
                        let productId = json["productList"][i]["productId"].stringValue
                        let actualPrice = json["productList"][i]["actualPrice"].stringValue
                        let discountValue = json["productList"][i]["discountValue"].stringValue
                        let wishlisted = json["productList"][i]["wishlisted"].boolValue
                        let stock = json["productList"][i]["stock"].stringValue
                        let description = json["productList"][i]["metaData"]["description"].stringValue
                        let name = json["productList"][i]["name"].stringValue
                        let dimension = json["productList"][i]["dimension"].stringValue
                        let discountedPrice = json["productList"][i]["discountedPrice"].stringValue
                        let rating = json["productList"][i]["rating"].stringValue
                        let discountType = json["productList"][i]["discountType"].stringValue
                        let itemId = json["productList"][i]["itemId"].stringValue
                        let categoryId = json["productList"][i]["categoryId"].stringValue
                        
                        var imgArr = [String]()
                        for j in 0..<json["productList"][i]["metaData"]["images"].count {
                            let file = json["productList"][i]["metaData"]["images"][j].stringValue
                            imgArr.append(file)
                        }
                        
                        
                        self.topDealsProductList.append(topDeals_Struct.init(currency: currency, productId: productId, name: name, description: description, dimension: dimension, wishlisted: wishlisted, discountType: discountType, itemId: itemId, categoryId: categoryId, actualPrice: actualPrice, discountValue: discountValue, stock: stock, discountedPrice: discountedPrice, rating: rating, images: imgArr))
                        
                    }
                    
                    if self.topDealsProductList.count > 0 {
                        self.categoriesCollView.isHidden = false
                        self.topDelasEmptyView.isHidden = true
                    } else {
                        self.categoriesCollView.isHidden = true
                        self.topDelasEmptyView.isHidden = false
                    }
                    
                    DispatchQueue.main.async {
                        self.categoriesCollView.reloadData()
                        hideAllProgressOnView(appDelegateInstance.window!)
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
    
    func getBanners() {
        if Reachability.isConnectedToNetwork(){
            
            showProgressOnView(appDelegateInstance.window!)
            
            //let country = "India"
            
            let apiUrl = BASE_URL + PROJECT_URL.GET_BANNERS
            
            ServerClass.sharedInstance.getRequestWithUrlParameters([:], path: apiUrl as String, successBlock: { (response) in
                
                print(response)
                let jsonData = try! response.rawData()
                let jsonDecoder = JSONDecoder()
                do{
                    self.bannersArr.removeAll()
                    let banners = try jsonDecoder.decode(GetBannerResponse.self, from: jsonData)
                    banners.bannerList?.forEach({ (banner) in
                        let bannerUrl = FILE_BASE_URL + "/\(banner)"
                        self.bannersArr.append(bannerUrl)
                    })
                    
                    DispatchQueue.main.async {
                        self.pagecontrol.numberOfPages = self.bannersArr.count
                        
                        self.bannerCollView.reloadData()
                        hideAllProgressOnView(appDelegateInstance.window!)
                    }
                }catch let error{
                    hideAllProgressOnView(appDelegateInstance.window!)
                    print(error.localizedDescription)
                }
                
                
            }) { (error) in
                hideAllProgressOnView(appDelegateInstance.window!)
                print(error.localizedDescription)
            }
        }
    }
    
    //    func getNewArrivals(_ country: String) {
    //        if Reachability.isConnectedToNetwork(){
    //
    //            showProgressOnView(appDelegateInstance.window!)
    //
    //            //let country = "India"
    //
    //            let apiUrl = BASE_URL + PROJECT_URL.NEW_ARRIVALS + country
    //
    //            let url : NSString = apiUrl as NSString
    //            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
    //
    //            ServerClass.sharedInstance.getRequestWithUrlParameters([:], path: urlStr as String, successBlock: { (response) in
    //
    //                print(response)
    //                let jsonData = try! response.rawData()
    //                let jsonDecoder = JSONDecoder()
    //                do{
    //                    self.newArrivalsProductList.removeAll()
    //                    let topDealsResponse = try jsonDecoder.decode(TopDeals.self, from: jsonData)
    //                    topDealsResponse.productList?.forEach({ (product) in
    //                        self.newArrivalsProductList.append(product)
    //                    })
    //
    //                    if self.newArrivalsProductList.count > 0 {
    //                        self.newArrivalCollView.isHidden = false
    //                        self.newArrivalEmptyView.isHidden = true
    //                    } else {
    //                        self.newArrivalCollView.isHidden = true
    //                        self.newArrivalEmptyView.isHidden = false
    //                    }
    //
    //                    DispatchQueue.main.async {
    //                        self.newArrivalCollView.reloadData()
    //                        hideAllProgressOnView(appDelegateInstance.window!)
    //                    }
    //                }catch let error{
    //                    hideAllProgressOnView(appDelegateInstance.window!)
    //                    print(error.localizedDescription)
    //                }
    //
    //
    //            }) { (error) in
    //                hideAllProgressOnView(appDelegateInstance.window!)
    //                print(error.localizedDescription)
    //            }
    //        }
    //    }
    
    func getNewArrivals(_ country: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            
            let apiUrl = BASE_URL + PROJECT_URL.NEW_ARRIVALS + country
            let url : NSString = apiUrl as NSString
            let urlStr : NSString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
            
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: urlStr as String, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.newArrivalsProductList.removeAll()
                    for i in 0..<json["productList"].count
                    {
                        let currency = json["productList"][i]["currency"].stringValue
                        let productId = json["productList"][i]["productId"].stringValue
                        let actualPrice = json["productList"][i]["actualPrice"].stringValue
                        let discountValue = json["productList"][i]["discountValue"].stringValue
                        let wishlisted = json["productList"][i]["wishlisted"].boolValue
                        let stock = json["productList"][i]["stock"].stringValue
                        let description = json["productList"][i]["metaData"]["description"].stringValue
                        let name = json["productList"][i]["name"].stringValue
                        let dimension = json["productList"][i]["dimension"].stringValue
                        let discountedPrice = json["productList"][i]["discountedPrice"].stringValue
                        let rating = json["productList"][i]["rating"].stringValue
                        let discountType = json["productList"][i]["discountType"].stringValue
                        let itemId = json["productList"][i]["itemId"].stringValue
                        let categoryId = json["productList"][i]["categoryId"].stringValue
                        
                        var imgArr = [String]()
                        for j in 0..<json["productList"][i]["metaData"]["images"].count {
                            let file = json["productList"][i]["metaData"]["images"][j].stringValue
                            imgArr.append(file)
                        }
                        
                        self.newArrivalsProductList.append(topDeals_Struct.init(currency: currency, productId: productId, name: name, description: description, dimension: dimension, wishlisted: wishlisted, discountType: discountType, itemId: itemId, categoryId: categoryId, actualPrice: actualPrice, discountValue: discountValue, stock: stock, discountedPrice: discountedPrice, rating: rating, images: imgArr))
                        
                    }
                    
                    if self.newArrivalsProductList.count > 0 {
                        self.newArrivalCollView.isHidden = false
                        self.newArrivalEmptyView.isHidden = true
                    } else {
                        self.newArrivalCollView.isHidden = true
                        self.newArrivalEmptyView.isHidden = false
                    }
                    
                    DispatchQueue.main.async {
                        self.newArrivalCollView.reloadData()
                        hideAllProgressOnView(appDelegateInstance.window!)
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
                    categoriesList.removeAll()
                    for i in 0..<json["categoryList"].count
                    {
                        let id = json["categoryList"][i]["id"].stringValue
                        let status = json["categoryList"][i]["status"].stringValue
                        let name = json["categoryList"][i]["name"].stringValue
                        // let metadata = json["categoryList"][i]["metaData"]
                        
                        let description = json["categoryList"][i]["metaData"]["description"].stringValue
                        let image = json["categoryList"][i]["metaData"]["image"].stringValue
                        let isSubCategoryAvailable = json["categoryList"][i]["isSubCategoryAvailable"].boolValue
                        
                        let parentCategory = json["categoryList"][i]["parentCategory"].stringValue
                        
                        categoriesList.append(categoryListStruct.init(id: id, status: status, name: name, description: description, image: image, isSubCategoryAvailable: isSubCategoryAvailable, parentCategory: parentCategory))
                        
                    }
                    
                    if categoriesList.count > 0 {
                        self.categoriesCollView.isHidden = false
                        //                        self.emptyView.isHidden = true
                    } else {
                        self.categoriesCollView.isHidden = false
                        //                        self.emptyView.isHidden = true
                    }
                    
                    DispatchQueue.main.async {
                        self.labelCollectionView.reloadData()
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
    
    
    @objc func slideToNext() {
        if currentCellIndex < self.bannersArr.count - 1 {
            currentCellIndex += 1
        } else {
            self.currentCellIndex = 0
        }
        self.pagecontrol.currentPage = currentCellIndex
        self.bannerCollView.scrollToItem(at: IndexPath(item: currentCellIndex, section: 0), at: .right, animated: true)
    }
    
    @IBAction func notificationsAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cartAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func countryAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ChooseCountryVC") as! ChooseCountryVC
        isHome = "yes"
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickTopDealsSeeAll(){
        let allProducts = storyboard?.instantiateViewController(withIdentifier: "AllProductsVC") as! AllProductsVC
        allProducts.productList = self.topDealsProductList
        allProducts.listType = "Top Deals"
        navigationController?.pushViewController(allProducts, animated: true)
    }
    
    @IBAction func onClickNewArrivalsSeeAll(){
        let allProducts = storyboard?.instantiateViewController(withIdentifier: "AllProductsVC") as! AllProductsVC
        allProducts.productList = self.newArrivalsProductList
        allProducts.listType = "New Arrivals"
        navigationController?.pushViewController(allProducts, animated: true)
    }
    
    
}

extension HomeNewVC: ChooseCountryDelegate{
    func onSelectCountry(country: Select_Country_List_Struct) {
        let flag = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.SELECTED_FLAG) as! String
        let imageUrl = FLAG_BASE_URL + "/" + flag
        self.countryButton.sd_setImage(with: URL(string: imageUrl), for: .normal)
    }
}

extension HomeNewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == labelCollectionView {
            return categoriesList.count
        } else if collectionView == bannerCollView {
            return bannersArr.count
        } else if collectionView == categoriesCollView{
            return topDealsProductList.count
        }else if collectionView == newArrivalCollView{
            return newArrivalsProductList.count
        }else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == labelCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeNewCollCell", for: indexPath) as! HomeNewCollCell
            let info = categoriesList[indexPath.row]
            cell.cellLbl.text = info.name
            return cell
        } else if collectionView == bannerCollView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeNewBannerCollCell", for: indexPath) as! HomeNewBannerCollCell
            cell.cellImg.layer.masksToBounds = true
            cell.cellImg.sd_setImage(with: URL(string: bannersArr[indexPath.row]), placeholderImage: UIImage(named: "edit cat_img"))
            //self.pagecontrol.currentPage = indexPath.row
            return cell
            
        } else if collectionView == categoriesCollView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollCell", for: indexPath) as! CategoriesCollCell
            cell.product = topDealsProductList[indexPath.row]
            
            return cell
        } else if collectionView == newArrivalCollView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewArrivalsCollCell", for: indexPath) as! NewArrivalsCollCell
            //            let info = newArrivalsProductList[indexPath.row]
            
            //            print(newArrivalsProductList[indexPath.row])
            cell.product = newArrivalsProductList[indexPath.row]
            
            return cell
            
        }else{
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isHome = "yes"
        if collectionView == categoriesCollView {
            let info = topDealsProductList[indexPath.row]
            //            let itemID = topDealsProductList[indexPath.item].itemID
            let itemID = info.itemId
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
            vc.itemID = itemID
            
            //            vc.productImgArr = topDealsProductList[indexPath.item].metaData!.images!
            vc.productImgArr = info.images!
            
            //            if let productImage = topDealsProductList[indexPath.item].metaData?.images?.first
            //            {
            //                vc.productImgStr = productImage
            //            }
            
            //            vc.productID = topDealsProductList[indexPath.item].productID
            vc.productID = info.productId
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if collectionView == newArrivalCollView {
            
            let info = newArrivalsProductList[indexPath.row]
            //            let itemID = newArrivalsProductList[indexPath.item].itemID
            let itemID = info.itemId
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
            vc.itemID = itemID
            //            if let productImage = newArrivalsProductList[indexPath.item].metaData?.images?.first
            //            {
            //                vc.productImgStr = productImage
            //            }
            
            //            vc.productImgArr = newArrivalsProductList[indexPath.item].metaData!.images!
            //            vc.productID = newArrivalsProductList[indexPath.item].productID
            vc.productImgArr = info.images!
            vc.productID = info.productId
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if collectionView == labelCollectionView {
            
            let info =  categoriesList[indexPath.row]
            if info.isSubCategoryAvailable {
                let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SubCategoriesVC") as! SubCategoriesVC
                vc.catInfo = info
                vc.catId = info.id
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductsVC") as! ProductsVC
                vc.catId = info.id
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == categoriesCollView{
            return 0
        }else if collectionView == self.labelCollectionView{
            return 0
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == categoriesCollView{
            return 0
        }else if collectionView == self.labelCollectionView{
            return 0
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == bannerCollView {
            self.pagecontrol.currentPage = indexPath.row
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.bannerCollView {
            
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else if collectionView == self.labelCollectionView {
            
            let collectionWidth = labelCollectionView.bounds.width
            let collectionHeight = labelCollectionView.bounds.height
            return CGSize(width: collectionWidth/5 - 50, height: collectionHeight)
        } else if collectionView == categoriesCollView {
            
            let collectionWidth = self.categoriesCollView.bounds.width
            return CGSize(width: collectionWidth / 3, height: 150)
        }else if collectionView == newArrivalCollView{
            let collectionWidth = self.newArrivalCollView.bounds.width
            if newArrivalsProductList.count <= 2{
                newArrivalCollHeight.constant = 150
            } else if newArrivalsProductList.count >= 2 && newArrivalsProductList.count <= 4{
                newArrivalCollHeight.constant = 300
            } else{
                newArrivalCollHeight.constant = 450
            }
            //            let collectionHeight = self.newArrivalCollView.bounds.height
            return CGSize(width: collectionWidth / 2, height: 150)
        }else {
            return CGSize()
        }
        
    }
    
}

extension HomeNewVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel clicked")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SearchProductsVC") as! SearchProductsVC
        //vc.catId = info.id
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

