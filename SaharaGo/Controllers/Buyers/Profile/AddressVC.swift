//
//  AddressVC.swift
//  SaharaGo
//
//  Created by Ritesh on 08/12/20.
//

import UIKit

struct address_Struct {
    var id:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var phone:String = ""
    var streetAddress :String = ""
    var country :String = ""
    var state:String = ""
    var city:String = ""
    var zipcode:String = ""
    var landmark:String = ""
    var isDefault :Bool = false
    var addressType:String = ""
    
}

class AddressVC: UIViewController {
    
    var addressArr = [address_Struct]()
    var defaultAddressArr = [address_Struct]()
    let addressTitleArray = ["Default Address", "Other Addresses"]

    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var completionHandlerCallback:((address_Struct?) ->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        isEdit = "no"
        self.getAddressAPI()
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
        print(indexPath!)
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
        vc.modalPresentationStyle = .fullScreen
        if indexPath?.section == 0 {
            vc.addressInfo = self.defaultAddressArr[indexPath!.row]
        } else {
            vc.addressInfo = self.addressArr[indexPath!.row]
        }
        
        isEdit = "yes"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        let indexPath: IndexPath? = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView))
        var info = address_Struct()
        if indexPath?.section == 0 {
            info = self.defaultAddressArr[indexPath!.row]
           // vc.addressInfo = self.defaultAddressArr[indexPath!.row]
        } else {
            info = self.addressArr[indexPath!.row]
           // vc.addressInfo = self.addressArr[indexPath!.row]
        }
        //let info = self.addressArr[indexPath!.row]
        self.deleteAddressAPI(info.id, rowId: indexPath!.row)
    }
    
    @IBAction func addNewAddressAction(_ sender: Any) {
        
        let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = userStoryboard.instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func getAddressAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.USER_GET_ADDRESSES, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    self.addressArr.removeAll()
                    self.defaultAddressArr.removeAll()
                    for i in 0..<json["addressList"].count {
                        let firstName =  json["addressList"][i]["metaData"]["firstName"].stringValue
                        let lastName =  json["addressList"][i]["metaData"]["lastName"].stringValue
                        let phone =  json["addressList"][i]["metaData"]["phone"].stringValue
                        let streetAddress =  json["addressList"][i]["metaData"]["streetAddress"].stringValue
                        let landmark =  json["addressList"][i]["metaData"]["landmark"].stringValue
                        let city =  json["addressList"][i]["metaData"]["city"].stringValue
                        let state =  json["addressList"][i]["metaData"]["state"].stringValue
                        let zipcode =  json["addressList"][i]["metaData"]["zipcode"].stringValue
                        let country =  json["addressList"][i]["metaData"]["country"].stringValue
                        let isDefault =  json["addressList"][i]["isDefault"].boolValue
                        let id =  json["addressList"][i]["id"].stringValue
                        let addressType =  json["addressList"][i]["metaData"]["addressType"].stringValue
                        
                        if isDefault {
                            self.defaultAddressArr.append(address_Struct.init(id: id, firstName: firstName, lastName: lastName, phone: phone, streetAddress: streetAddress, country: country, state: state, city: city, zipcode: zipcode, landmark: landmark, isDefault: isDefault, addressType: addressType))
                        } else {
                            self.addressArr.append(address_Struct.init(id: id, firstName: firstName, lastName: lastName, phone: phone, streetAddress: streetAddress, country: country, state: state, city: city, zipcode: zipcode, landmark: landmark, isDefault: isDefault, addressType: addressType))
                        }
                        
                        
                    }
                    
                    if self.addressArr.count > 0 || self.defaultAddressArr.count > 0 {
                        self.tableView.isHidden = false
                        self.emptyView.isHidden = true
                    } else {
                        self.tableView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                } else {
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
    
    func deleteAddressAPI(_ id: String, rowId: Int) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let fullUrl = BASE_URL + PROJECT_URL.USER_DELETE_ADDRESS + id
            let param:[String:String] = [:]
            
            ServerClass.sharedInstance.deleteRequestWithUrlParameters(param, path: fullUrl, successBlock: {  (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                
                if success  == "true"
                {
                    self.view.makeToast(json["message"].stringValue)
                    self.getAddressAPI()
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

extension AddressVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return addressTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return self.defaultAddressArr.count
            
        }else {
            return  self.addressArr.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressCell
        
        if indexPath.section == 0 {
            let info = self.defaultAddressArr[indexPath.row]
            cell.cellLbl.text = "\(info.firstName) \(info.lastName)"
            cell.cellSubLbl.text = "\(info.streetAddress), \(info.city), \(info.country)\nMobile:\(info.phone)"
            
        }else{
            let info = self.addressArr[indexPath.row]
            cell.cellLbl.text = "\(info.firstName) \(info.lastName)"
            cell.cellSubLbl.text = "\(info.streetAddress), \(info.city), \(info.country)\nMobile:\(info.phone)"
            
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if self.completionHandlerCallback != nil {
                self.completionHandlerCallback!(self.defaultAddressArr[indexPath.row])
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            if self.completionHandlerCallback != nil {
                self.completionHandlerCallback!(self.addressArr[indexPath.row])
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        headerView.backgroundColor = .white
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.width - 10, height: headerView.frame.height - 10))
        headerLabel.text = addressTitleArray[section].uppercased()

        headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        if section == 0{
            if defaultAddressArr.count > 0{
                headerView.addSubview(headerLabel)
            }
        }
        
        if section == 1{
            if addressArr.count > 0{
                headerView.addSubview(headerLabel)
            }
        }
        
        
        
        
        return headerView

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    
    
}
