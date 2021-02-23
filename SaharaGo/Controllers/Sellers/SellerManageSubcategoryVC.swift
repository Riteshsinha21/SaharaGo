//
//  SellerManageSubcategoryVC.swift
//  SaharaGo
//
//  Created by Ritesh on 12/01/21.
//

import UIKit

class SellerManageSubcategoryVC: UIViewController {

    @IBOutlet var emptyView: UIView!
    @IBOutlet var headerTitleTxt: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var catId: String = String()
    var headerTitleLbl = ""
    var categoriesList = [categoryListStruct]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getSubCategoriesofCategoryAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        isCategoryEdit = "no"
        self.headerTitleTxt.text = self.headerTitleLbl
    }
    
    
    @IBAction func editAction(_ sender: UIButton) {
        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
        isSubcategory = "no"
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
        let info = self.categoriesList[indexPath!.row]
        isCategoryEdit = "yes"
        //categoryId = info.id
        vc.catInfo = info
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addCategoriesAction(_ sender: Any) {
        isSubcategory = "no"
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
        
        categoryId = "0"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        categoryIdArr.removeLastObject()
        self.dismiss(animated: true, completion: nil)
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

}

extension SellerManageSubcategoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCategoriesCell", for: indexPath) as! ManageCategoriesCell
        let info = self.categoriesList[indexPath.row]
        cell.cellTitleLbl.text = info.name
        cell.cellDescLbl.text = info.description
        cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
        if info.isSubCategoryAvailable {
            cell.celleditbtn.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = self.categoriesList[indexPath.row]
        if info.isSubCategoryAvailable {
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
             let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerManageSubcategoryVC") as! SellerManageSubcategoryVC
             vc.catId = info.id
             vc.headerTitleLbl = info.name
             categoryIdArr.add(info.id)
            // vc.isSubCategoryAvailable = isSubCategoryAvailable
             vc.modalPresentationStyle = .fullScreen
             self.present(vc, animated: true, completion: nil)
        } else {
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SourcingProductsVC") as! SourcingProductsVC
            vc.catId = info.id
            categoryIdArr.add(info.id)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
