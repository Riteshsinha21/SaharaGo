//
//  SellerChooseSubCategoryVC.swift
//  SaharaGo
//
//  Created by Ritesh on 06/01/21.
//

import UIKit

class SellerChooseSubCategoryVC: UIViewController {

    var catId: String = String()
    var selectedInfo = categoryListStruct()
    var isSubCategoryAvailable: Bool = false
    
    @IBOutlet var headerTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        isSubcategory = "no"
        isAddProduct = "no"
        self.headerTitle.text = self.selectedInfo.name
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addSubcategoryVC(_ sender: Any) {
        isSubcategory = "yes"
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddCategoryVC") as! SellerAddCategoryVC
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addProductVC(_ sender: Any) {
        isAddProduct = "yes"
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerAddProductsVC") as! SellerAddProductsVC
        vc.catId = categoryId
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
