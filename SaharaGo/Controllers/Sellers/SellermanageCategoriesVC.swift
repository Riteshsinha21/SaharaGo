//
//  SellermanageCategoriesVC.swift
//  SaharaGo
//
//  Created by Ritesh on 12/01/21.
//

import UIKit

class SellermanageCategoriesVC: UIViewController {
    
    @IBOutlet var catEmptyView: UIView!
    @IBOutlet var PendingCategoriesBtn: UIButton!
    @IBOutlet var categoriesBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    
    var categoriesList = [categoryListStruct]()
    var pendingCategoriesList = [categoryListStruct]()
    let addressTitleArray = ["Categories", "Pending Categories"]
    var catType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.getCategoriesList()
        
        self.categoriesBtn.layer.cornerRadius = 15
        self.categoriesBtn.backgroundColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
        self.categoriesBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
        self.categoriesBtn.borderWidth = 1
        self.categoriesBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        
        self.PendingCategoriesBtn.layer.cornerRadius = 15
        self.PendingCategoriesBtn.backgroundColor = .white
        self.PendingCategoriesBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
        self.PendingCategoriesBtn.borderWidth = 1
        self.PendingCategoriesBtn.setTitleColor(#colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isCategoryEdit = "no"
        
        //self.getPendingCategoriesList()
    }
    
    @IBAction func notificationsAction(_ sender: Any) {
        isSubcategory = "no"
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerNotificationVC") as! SellerNotificationVC
        
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
        categoryIdArr.removeAllObjects()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editBtnAction(_ sender: UIButton) {
        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
        isSubcategory = "no"
        if indexPath?.section == 0 {
            
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
            let info = self.categoriesList[indexPath!.row]
            isCategoryEdit = "yes"
            //categoryId = info.id
            vc.catInfo = info
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } else {
            
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
            let info = self.pendingCategoriesList[indexPath!.row]
            isCategoryEdit = "yes"
            //categoryId = info.id
            vc.catInfo = info
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func reasonAction(_ sender: UIButton) {
        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
        let info = self.pendingCategoriesList[indexPath!.row]
        
        UIAlertController.showInfoAlertWithTitle("Rejection Reason", message: info.comment, buttonTitle: "OK", viewController: self)
    }
    
    @IBAction func categoriesAction(_ sender: Any) {
        self.getCategoriesList()
        
        UIView.animate(withDuration: 0.5) {
            self.categoriesBtn.layer.cornerRadius = 15
            self.categoriesBtn.backgroundColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
            self.categoriesBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
            self.categoriesBtn.borderWidth = 1
            self.categoriesBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            
            self.PendingCategoriesBtn.layer.cornerRadius = 15
            self.PendingCategoriesBtn.backgroundColor = .white
            self.PendingCategoriesBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
            self.PendingCategoriesBtn.borderWidth = 1
            self.PendingCategoriesBtn.setTitleColor(#colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1), for: .normal)
            
        }
        
    }
    
    @IBAction func pendingcategoryAction(_ sender: Any) {
        self.getPendingCategoriesList()
        
        UIView.animate(withDuration: 0.5) {
            self.PendingCategoriesBtn.layer.cornerRadius = 15
            self.PendingCategoriesBtn.backgroundColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
            self.PendingCategoriesBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
            self.PendingCategoriesBtn.borderWidth = 1
            self.PendingCategoriesBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            
            self.categoriesBtn.layer.cornerRadius = 15
            self.categoriesBtn.backgroundColor = .white
            self.categoriesBtn.borderColor = #colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1)
            self.categoriesBtn.borderWidth = 1
            self.categoriesBtn.setTitleColor(#colorLiteral(red: 0.6823529412, green: 0.5490196078, blue: 0.1960784314, alpha: 1), for: .normal)
            
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
                    self.categoriesList.removeAll()
                    self.catType = "Categories"
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
                    
                    //                    if self.categoriesList.count > 0 {
                    //                        self.tableView.isHidden = false
                    //                        self.emptyView.isHidden = true
                    //                    } else {
                    //                        self.tableView.isHidden = true
                    //                        self.emptyView.isHidden = false
                    //                    }
                    
                    if self.categoriesList.count > 0 {
                        self.tableView.isHidden = false
                        self.catEmptyView.isHidden = true
                    } else {
                        self.tableView.isHidden = true
                        self.catEmptyView.isHidden = false
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
    
    func getPendingCategoriesList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_GET_ADDED_CATEGORY, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    self.categoriesList.removeAll()
                    self.catType = "Pending Categories"
                    for i in 0..<json["categoryList"].count
                    {
                        let id = json["categoryList"][i]["id"].stringValue
                        
                        let status = json["categoryList"][i]["status"].stringValue
                        let name = json["categoryList"][i]["name"].stringValue
                        let isSubCategoryAvailable = json["categoryList"][i]["isSubCategoryAvailable"].boolValue
                        
                        let parentCategory = json["categoryList"][i]["parentCategory"].stringValue
                        
                        let comment = json["categoryList"][i]["comment"].stringValue
                        
                        // let metadata = json["categoryList"][i]["metaData"]
                        
                        let description = json["categoryList"][i]["metaData"]["description"].stringValue
                        let image = json["categoryList"][i]["metaData"]["image"].stringValue
                        
                        self.categoriesList.append(categoryListStruct.init(id: id, status: status, name: name, description: description, image: image, isSubCategoryAvailable: isSubCategoryAvailable, parentCategory: parentCategory, comment: comment))
                    }
                    
                    //                    if self.pendingCategoriesList.count > 0 {
                    //                        self.tableView.isHidden = false
                    //                        self.emptyView.isHidden = true
                    //                    } else {
                    //                        self.tableView.isHidden = true
                    //                        self.emptyView.isHidden = false
                    //                    }
                    
                    if self.categoriesList.count > 0 {
                        self.tableView.isHidden = false
                        self.catEmptyView.isHidden = true
                    } else {
                        self.tableView.isHidden = true
                        self.catEmptyView.isHidden = false
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
    
    //    func addReadMoreString(to label: UILabel?) {
    //    let readMoreText = " ...Read More"
    //    let lengthForString = label?.text?.count ?? 0
    //    if lengthForString >= 30 {
    //        let lengthForVisibleString = fit(label?.text, into: label)
    //        var mutableString = label?.text ?? ""
    //        let trimmedString = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: (label?.text?.count ?? 0) - lengthForVisibleString), with: "")
    //        let readMoreLength = readMoreText.count
    //        let trimmedForReadMore = (trimmedString as NSString).replacingCharacters(in: NSRange(location: trimmedString.count - readMoreLength, length: readMoreLength), with: "")
    //        var answerAttributed: NSMutableAttributedString? = nil
    //        if let font = label?.font {
    //        answerAttributed = NSMutableAttributedString(
    //            string: trimmedForReadMore,
    //            attributes: [
    //                NSAttributedString.Key.font: label.font
    //            ])
    //
    //            let readMoreAttributed = NSMutableAttributedString(
    //                string: readMoreText,
    //                attributes: [
    //                    NSAttributedString.Key.font: Font(TWRegular, 12.0),
    //                    NSAttributedString.Key.foregroundColor: White
    //                ])
    //
    //            answerAttributed.append(readMoreAttributed)
    //            label.attributedText = answerAttributed
    //
    //            let readMoreGesture = UITagTapGestureRecognizer(target: self, action: #selector(readMoreDidClickedGesture(_:)))
    //            readMoreGesture.tag = 1
    //            readMoreGesture.numberOfTapsRequired = 1
    //            label.addGestureRecognizer(readMoreGesture)
    //
    //            label.isUserInteractionEnabled = true
    //        } else {
    //            print("No need of read more")
    //        }
    //
    //    }
    //    }
    
}

extension SellermanageCategoriesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if section == 0 {
        //            return self.categoriesList.count
        //        } else {
        //            return self.pendingCategoriesList.count
        //        }
        
        return self.categoriesList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if indexPath.section == 0 {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCategoriesCell", for: indexPath) as! ManageCategoriesCell
        //            let info = self.categoriesList[indexPath.row]
        //            cell.cellTitleLbl.text = info.name
        //            cell.cellDescLbl.text = info.description
        //            cell.celleditbtn.isHidden = true
        //            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
        ////            if info.isSubCategoryAvailable {
        ////                cell.celleditbtn.isHidden = true
        ////            } else {
        ////                cell.celleditbtn.isHidden = false
        ////            }
        //            return cell
        //        } else {
        //
        //            let info = self.pendingCategoriesList[indexPath.row]
        //            if info.status == "Rejected" {
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCategoriesCell", for: indexPath) as! ManageCategoriesCell
        //                cell.cellTitleLbl.text = info.name
        //                cell.cellDescLbl.text = info.description
        //                cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
        //                cell.cellRejectImg.isHidden = false
        //                cell.cellReasonBtn.isHidden = false
        //                cell.celleditbtn.isHidden = false
        //                return cell
        //            } else {
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCategoriesCell", for: indexPath) as! ManageCategoriesCell
        //                cell.cellTitleLbl.text = info.name
        //                cell.cellDescLbl.text = info.description
        //                cell.cellRejectImg.isHidden = true
        //                cell.cellReasonBtn.isHidden = true
        //                cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
        //                cell.celleditbtn.isHidden = false
        //
        //                //            if info.isSubCategoryAvailable {
        //                //                cell.celleditbtn.isHidden = true
        //                //            } else {
        //                //                cell.celleditbtn.isHidden = false
        //                //            }
        //                return cell
        //            }
        //
        //        }
        if self.catType == "Categories" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCategoriesCell", for: indexPath) as! ManageCategoriesCell
            let info = self.categoriesList[indexPath.row]
            cell.cellTitleLbl.text = info.name
            cell.cellDescLbl.text = info.description
            cell.celleditbtn.isHidden = true
            cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
            
            return cell
        } else {
            let info = self.categoriesList[indexPath.row]
            if info.status == "Rejected" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCategoriesCell", for: indexPath) as! ManageCategoriesCell
                cell.cellTitleLbl.text = info.name
                cell.cellDescLbl.text = info.description
                cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
                cell.cellRejectImg.isHidden = false
                cell.cellReasonBtn.isHidden = false
                cell.celleditbtn.isHidden = false
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCategoriesCell", for: indexPath) as! ManageCategoriesCell
                cell.cellTitleLbl.text = info.name
                cell.cellDescLbl.text = info.description
                cell.cellRejectImg.isHidden = true
                cell.cellReasonBtn.isHidden = true
                cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.image)"), placeholderImage: UIImage(named: "edit cat_img"))
                cell.celleditbtn.isHidden = false
                
                //            if info.isSubCategoryAvailable {
                //                cell.celleditbtn.isHidden = true
                //            } else {
                //                cell.celleditbtn.isHidden = false
                //            }
                return cell
            }
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        if indexPath.section == 0 {
        //            let info = self.categoriesList[indexPath.row]
        //            if info.isSubCategoryAvailable {
        //                let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        //                 let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerManageSubcategoryVC") as! SellerManageSubcategoryVC
        //                 vc.catId = info.id
        //                 vc.headerTitleLbl = info.name
        //                 categoryIdArr.add(info.id)
        //                // vc.isSubCategoryAvailable = isSubCategoryAvailable
        //                 vc.modalPresentationStyle = .fullScreen
        //                 self.present(vc, animated: true, completion: nil)
        //            } else {
        //                let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        //                let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SourcingProductsVC") as! SourcingProductsVC
        //                vc.catId = info.id
        //                categoryIdArr.add(info.id)
        //                vc.modalPresentationStyle = .fullScreen
        //                self.present(vc, animated: true, completion: nil)
        //            }
        //        }
        
        if self.catType == "Categories" {
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
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
    //        headerView.backgroundColor = .clear
    //        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.width - 10, height: headerView.frame.height - 10))
    //        headerLabel.text = addressTitleArray[section].uppercased()
    //
    //        headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
    //
    //        if section == 0{
    //            if self.categoriesList.count > 0{
    //                headerView.addSubview(headerLabel)
    //            }
    //        }
    //
    //        if section == 1{
    //            if self.pendingCategoriesList.count > 0{
    //                headerView.addSubview(headerLabel)
    //            }
    //        }
    //
    //
    //
    //
    //        return headerView
    //
    //    }
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 40
    //    }
}
