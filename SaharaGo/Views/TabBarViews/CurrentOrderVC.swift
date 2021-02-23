//
//  CurrentOrderVC.swift
//  SaharaGo
//
//  Created by Ashish Nimbria on 1/4/21.
//

import UIKit

class CurrentOrderVC: UIViewController {

    @IBOutlet var prodImg: UIImageView!
    @IBOutlet var productQuantity: UILabel!
    @IBOutlet var customerName: UILabel!
    @IBOutlet var productPrice: UILabel!
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var shippingAddressLbl: UILabel!
    @IBOutlet var cutomerDetailsLbl: UILabel!
    
    var orderDetailInfo = current_order_Address_main_struct()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(orderDetailInfo)
        self.setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }

    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func notificationAction(_ sender: Any) {
            
            
    //        let indexPath: IndexPath? = tableView.indexPathForRow(at: (sender as AnyObject).convert(CGPoint.zero, to: tableView))
    //        let catinfo = self.categoriesList[indexPath!.row]
            isSubcategory = "no"
            let sellerStoryboard: UIStoryboard = UIStoryboard(name: "Seller", bundle: nil)
            let vc = sellerStoryboard.instantiateViewController(withIdentifier: "SellerNotificationVC") as! SellerNotificationVC
            
    //        categoryId = "0"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    
    
    private func setData() {
        self.cutomerDetailsLbl.text = "\(self.orderDetailInfo.firstName) \(self.orderDetailInfo.lastName)\n\(self.orderDetailInfo.phone)\nOrder Sate: \(self.orderDetailInfo.orderState)\nOrder Id: \(self.orderDetailInfo.orderId)\nTotal Order Price: \(self.orderDetailInfo.totalPrice)"
        
        self.shippingAddressLbl.text = "\(self.orderDetailInfo.streetAddress)\n\(self.orderDetailInfo.landmark)\n\(self.orderDetailInfo.city), \(self.orderDetailInfo.state)\n\(self.orderDetailInfo.zipcode)\n\(self.orderDetailInfo.country)"
        
        self.productTitle.text = self.orderDetailInfo.cartMetaData[0].name
        self.productPrice.text = "\(self.orderDetailInfo.cartMetaData[0].currency) \(self.orderDetailInfo.cartMetaData[0].discountedPrice)"
        self.productQuantity.text = self.orderDetailInfo.cartMetaData[0].quantity
        self.customerName.text = "\(self.orderDetailInfo.firstName) \(self.orderDetailInfo.lastName)"
        
        if self.orderDetailInfo.cartMetaData[0].metaData.images.count > 0 {
            self.prodImg?.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(self.orderDetailInfo.cartMetaData[0].metaData.images[0])"), placeholderImage: UIImage(named: "edit cat_img"))
           // cell.productImageView?.sd_setImage(with: URL(string: FILE_BASE_URL + "/\(info.cartMetaData[0].metaData.images[0])"), placeholderImage: UIImage(named: "edit cat_img"))
        }
        
    }

}
