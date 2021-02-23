//
//  HomeVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit
import SQLite

class HomeVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    
    
    var database : Connection!
    let productsTable = Table("products")
    let id = Expression<Int>("id")
    let prodId = Expression<String>("prodId")
    let prodName = Expression<String>("prodName")
    let prodDescription = Expression<String>("prodDescription")
    let productStock = Expression<String>("prodStock")
    let productPrice = Expression<String>("prodPrice")
    let prodCurrency = Expression<String>("prodCurrency")
    let prodDiscountPercent = Expression<String>("prodDiscountPercent")
    let prodDiscountPrice = Expression<String>("prodDiscountPrice")
    let prodCount = Expression<Int>("prodCount")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.getCategoriesList()
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
        
        self.navigationController?.navigationBar.isHidden = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "cart"), style: .plain, target: self, action: #selector(cartTapped))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "country"), style: .plain, target: self, action: #selector(countryTapped))

        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func countryTapped() {
        
    }
    
    @objc func cartTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
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
            table.column(self.prodId)
            table.column(self.prodCount)
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
                        
                        categoriesList.append(categoryListStruct.init(id: id, status: status, name: name, description: description, image: image ))
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    print(categoriesList)
                    
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
    
    //    func getCategoriesProductsList(catId: String) {
    //        if Reachability.isConnectedToNetwork() {
    //            showProgressOnView(appDelegateInstance.window!)
    //
    //            var  apiUrl =  BASE_URL + PROJECT_URL.USER_GET_PRODUCTS
    //            apiUrl = apiUrl + "India/" + "1/" + "10/" + "?\(catId)"
    //            {country}/{pageNumber}/{limit}?categoryId=&search=&sort=
    //            let param:[String:String] = [:]
    //            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: apiUrl, successBlock: { (json) in
    //                print(json)
    //                hideAllProgressOnView(appDelegateInstance.window!)
    //                let success = json["success"].stringValue
    //                if success == "true"
    //                {
    //                    self.userProductListArr.removeAll()
    //                    for i in 0..<json["productList"].count
    //                    {
    //                        let currency = json["productList"][i]["currency"].stringValue
    //                        let description = json["productList"][i]["metaData"]["description"].stringValue
    //                        let category = json["productList"][i]["category"].stringValue
    //                        let stock = json["productList"][i]["stock"].stringValue
    //                        let productId = json["productList"][i]["productId"].stringValue
    //                        let price = json["productList"][i]["price"].stringValue
    //                        let discountedPrice = json["productList"][i]["discountedPrice"].stringValue
    //                        let rating = json["productList"][i]["rating"].stringValue
    //
    //                        let discountPercent = json["productList"][i]["discountPercent"].stringValue
    //                        let name = json["productList"][i]["name"].stringValue
    //
    //                        self.userProductListArr.append(categoryProductListStruct.init(currency: currency, description: description, category: category, stock: stock, productId: productId, price: price, discountedPrice: discountedPrice, discountPercent: discountPercent, rating: rating, name: name))
    //
    //                    }
    //
    //                    print(self.userProductListArr)
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
    
    //    var  apiUrl =  BASE_URL + PROJECT_URL.VENDOR_GET_CATEGORY_PRODUCTS
    //    apiUrl = apiUrl + "\(catId)"
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        } else if indexPath.section == 1 {
            return 140
        } else {
            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTopCategoriesCell", for: indexPath) as! HomeTopCategoriesCell
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeSliderCell", for: indexPath) as! HomeSliderCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeRecommendedCell", for: indexPath) as! HomeRecommendedCell
            
            cell.categoriesList = categoriesList
            DispatchQueue.main.async {
                cell.renderUI()
            }
            
            return cell
        }
        
    }
    
    
}
