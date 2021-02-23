//
//  SellerViewProductsVC.swift
//  SaharaGo
//
//  Created by Ritesh on 18/01/21.
//

import UIKit

class SellerViewProductsVC: UIViewController {
    
    var prodcuctImgArr = [String]()
    var completionHandlerCallback:(([String]) ->Void)?

    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cellDeleteAction(_ sender: UIButton) {
        let indexPath: IndexPath? = collectionView.indexPathForItem(at: sender.convert(CGPoint.zero, to: collectionView))
        self.prodcuctImgArr.remove(at: indexPath!.row)
        
        if self.completionHandlerCallback != nil {
            self.completionHandlerCallback!(self.prodcuctImgArr)
            
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SellerViewProductsVC:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prodcuctImgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SellerViewProductsCollCell", for: indexPath) as! SellerViewProductsCollCell
             
             if self.prodcuctImgArr.count > 0 {
                 cell.cellImg.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(self.prodcuctImgArr[indexPath.row])"), placeholderImage: UIImage(named: "edit cat_img"))
                
             }
        
             return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.width
        return CGSize(width: collectionWidth / 2 - 10, height: collectionWidth / 2 + 80)
    }
    
}
