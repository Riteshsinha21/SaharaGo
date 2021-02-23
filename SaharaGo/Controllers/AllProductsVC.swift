//
//  AllProductsVC.swift
//  SaharaGo
//
//  Created by Ashish Nimbria on 12/31/20.
//

import UIKit

class AllProductsVC: UIViewController {

    @IBOutlet var emptyView: UIView!
    @IBOutlet weak var allProductsCollView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
//    var productList = [TopDealsProductList]()
    var productList = [topDeals_Struct]()
    var listType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        if listType == "Top Deals"{
            titleLabel.text = "Top Deals"
        }else{
            titleLabel.text = "New Arrivals"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        if self.productList.count > 0 {
            self.emptyView.isHidden = true
            self.allProductsCollView.isHidden = false
        } else {
            self.emptyView.isHidden = false
            self.allProductsCollView.isHidden = true
        }
    }
    
    @IBAction func onClickBack(){
        navigationController?.popViewController(animated: true)
    }

}

extension AllProductsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollCell", for: indexPath) as! CategoriesCollCell
        cell.product = productList[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let info = productList[indexPath.item]
//        let itemID = productList[indexPath.item].itemID
        let itemID = info.itemId
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        vc.itemID = itemID
        
        vc.productImgArr = info.images!
//        if let productImage = productList[indexPath.item].metaData?.images?.first
//        {
//            vc.productImgStr = productImage
//        }
        
//        vc.productID = productList[indexPath.item].productID
        vc.productID = info.productId
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionWidth = self.allProductsCollView.bounds.width
        return CGSize(width: collectionWidth / 3, height: 150)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
