//
//  SourcingVC.swift
//  SaharaGo
//
//  Created by Ritesh on 14/12/20.
//

import UIKit

class SourcingVC: UIViewController {
    
    
    var categoriesList = [categoryListStruct]()

    @IBOutlet var emptyView: UIView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       // self.getCategoriesList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.getCategoriesList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        categoryIdArr.removeAllObjects()
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCategoryAction(_ sender: Any) {
        
        isSubcategory = "no"
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
        
        categoryId = "0"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
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
                        // let metadata = json["categoryList"][i]["metaData"]
                        
                        let description = json["categoryList"][i]["metaData"]["description"].stringValue
                        let image = json["categoryList"][i]["metaData"]["image"].stringValue
                        let isSubCategoryAvailable = json["categoryList"][i]["isSubCategoryAvailable"].boolValue
                        
                        let parentCategory = json["categoryList"][i]["parentCategory"].stringValue
                        
                        self.categoriesList.append(categoryListStruct.init(id: id, status: status, name: name, description: description, image: image, isSubCategoryAvailable: isSubCategoryAvailable, parentCategory: parentCategory))
                        
                    }
                    
                    if self.categoriesList.count > 0 {
                        self.collectionView.isHidden = false
                        self.emptyView.isHidden = true
                    } else {
                        self.collectionView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
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

extension SourcingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoriesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollCell", for: indexPath) as! CategoriesCollCell
        let info = self.categoriesList[indexPath.row]
        cell.cellLbl.text = info.name
        
        let imgUrl = "\(FILE_BASE_URL)/\(info.image)"
        cell.cellImg.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "edit cat_img"))
        //cell.setViewDocUploadCellData(docLabelArr, docValueArr: docUrlArr)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let info = self.categoriesList[indexPath.row]
        if info.isSubCategoryAvailable {
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SourcingSubCategoriesVC") as! SourcingSubCategoriesVC
            vc.catInfo = info
            vc.catId = info.id
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
           // self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SourcingProductsVC") as! SourcingProductsVC
            vc.catId = info.id
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            //self.navigationController?.pushViewController(vc, animated: true)
        }
        categoryIdArr.add(info.id)
        
    }
    
}

extension SourcingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let collectionWidth = collectionView.bounds.width
    //        return CGSize(width: (UIScreen.main.bounds.size.width - 30) / 2.0, height: (UIScreen.main.bounds.size.height))
            return CGSize(width: collectionWidth/3 - 10, height: 135)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 10
        }
    
}
