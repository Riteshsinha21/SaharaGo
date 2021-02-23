//
//  HomeTopCategoriesCell.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit

class HomeTopCategoriesCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    
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

}

extension HomeTopCategoriesCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTopCategoriesCollCell", for: indexPath) as! HomeTopCategoriesCollCell
        
        return cell
    }
    
    
}

extension HomeTopCategoriesCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let collectionWidth = collectionView.bounds.width
            let collectionHeight = collectionView.bounds.height
    //        return CGSize(width: (UIScreen.main.bounds.size.width - 30) / 2.0, height: (UIScreen.main.bounds.size.height))
            return CGSize(width: collectionWidth/5 - 50, height: collectionHeight)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 50
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 50
        }
    
}
