//
//  HomeRecommendedCell.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit

class HomeRecommendedCell: UITableViewCell {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var categoriesList = [categoryListStruct]()
    var selectionHandler:((Int)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func renderUI(){
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
        })
    }
    
}

extension HomeRecommendedCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoriesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeRecommendedCollCell", for: indexPath) as! HomeRecommendedCollCell
        let info =  categoriesList[indexPath.row]
        cell.cellLbl.text = info.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let info =  categoriesList[indexPath.row]
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "ProductsVC") as! ProductsVC
        vc.catId = info.id
        vc.modalPresentationStyle = .fullScreen
        topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeRecommendedCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.width
        let collectionHeight = collectionView.bounds.height
        //        return CGSize(width: (UIScreen.main.bounds.size.width - 30) / 2.0, height: (UIScreen.main.bounds.size.height))
        //return CGSize(width: collectionWidth/2 - 20, height: collectionWidth)
        return CGSize(width: collectionWidth/3 - 10, height: collectionWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

extension UIView {
    func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
