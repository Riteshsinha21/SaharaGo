//
//  CategoriesVC.swift
//  SaharaGo
//
//  Created by Ritesh on 09/12/20.
//

import UIKit

class CategoriesVC: SuperViewController {

    var categoriesListCopy = [categoryListStruct]()
    
    @IBOutlet var cartBadgeLbl: UILabel!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBar.delegate = self
        self.categoriesListCopy = categoriesList
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge(_:)), name: Notification.Name("updateCartBadge"), object: nil)
        
        self.cartBadgeLbl.isHidden = true
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                self.cartBadgeLbl.isHidden = true
            } else {
                //self.cartBadgeLbl.isHidden = false
                self.cartBadgeLbl.text = "\(cartCount)"
            }
            
        }
        
    }
    
    @objc func updateCartBadge(_ notification: Notification) {
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                self.cartBadgeLbl.isHidden = true
            } else {
               // self.cartBadgeLbl.isHidden = false
                let cartCountDic = notification.userInfo?["userInfo"] as? [String: Any] ?? [:]
                self.cartBadgeLbl.text = "\(String(describing: cartCountDic["cartCount"]!))"
            }
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = "Shop by Category"
        
        guard let countryColorStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.COUNTRY_COLOR_CODE) as? String else {return}
        guard let rgba = countryColorStr.slice(from: "(", to: ")") else { return }
        let myStringArr = rgba.components(separatedBy: ",")
        self.tabBarController?.tabBar.tintColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        self.navigationController?.navigationBar.barTintColor = UIColor(red: CGFloat((myStringArr[0] as NSString).doubleValue/255.0), green: CGFloat((myStringArr[1] as NSString).doubleValue/255.0), blue: CGFloat((myStringArr[2] as NSString).doubleValue/255.0), alpha: CGFloat((myStringArr[3] as NSString).doubleValue))
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        self.makeNavCartBtn()
      // navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "cart"), style: .plain, target: self, action: #selector(cartTapped))

        self.tabBarController?.tabBar.isHidden = false
        
        if categoriesListCopy.count > 0 {
            self.collectionView.isHidden = false
            self.emptyView.isHidden = true
        } else {
            self.collectionView.isHidden = false
            self.emptyView.isHidden = true
        }
    }
    
    func makeNavCartBtn() {
        
        if let cartCount = UserDefaults.standard.value(forKey: "cartCount") as? Int {
            if cartCount == 0 {
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "cart"), style: .plain, target: self, action: #selector(cartTapped))
                
            } else {
                
                let filterBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
                filterBtn.setImage(UIImage.init(named: "cart"), for: .normal)
                filterBtn.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
                
                let lblBadge = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 15, height: 15))
                lblBadge.backgroundColor = UIColor.red
                lblBadge.clipsToBounds = true
                lblBadge.layer.cornerRadius = 7
                lblBadge.textColor = UIColor.white
                // lblBadge.font = FontLatoRegular(s: 10)
                lblBadge.textAlignment = .center
                lblBadge.text = "\(cartCount)"
                
                filterBtn.addSubview(lblBadge)
                
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: filterBtn)]
            }
        }
        
        
        
        
    }

    @objc func cartTapped() {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func cartAction(_ sender: Any) {
        let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = sellerStoryboard.instantiateViewController(withIdentifier: "CartNewVC") as! CartNewVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoriesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesListCopy.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollCell", for: indexPath) as! CategoriesCollCell
        let info = categoriesListCopy[indexPath.row]
        cell.cellLbl.text = info.name
        
        let imgUrl = "\(FILE_BASE_URL)/\(info.image)"
        cell.cellImg.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "edit cat_img"))
        //cell.setViewDocUploadCellData(docLabelArr, docValueArr: docUrlArr)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let info =  categoriesListCopy[indexPath.row]
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

extension CategoriesVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            self.categoriesListCopy = categoriesList
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                self.categoriesListCopy = categoriesList
                if searchText.isEmpty {
                    self.categoriesListCopy = categoriesList
                } else {
                    self.categoriesListCopy = self.categoriesListCopy.filter({ (item) -> Bool in
                        return item.name.contains(searchText)
                    })
                    
    //                self.CountryList = self.CountryList.sorted(by: { (i1, i2) -> Bool in
    //                    return i1.countryName.contains(searchText)
    //                })

                }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
                
                print("searchText \(searchText)")
            }
}
