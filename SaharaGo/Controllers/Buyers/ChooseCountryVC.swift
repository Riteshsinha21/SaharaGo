//
//  ChooseCountryVC.swift
//  SaharaGo
//
//  Created by Ritesh on 16/12/20.
//

import UIKit
import SDWebImage

struct Select_Country_List_Struct {
    var countryName:String = ""
    var colorCode: String = ""
    var flagName: String = ""
}

protocol ChooseCountryDelegate {
    func onSelectCountry(country: Select_Country_List_Struct)
}

class ChooseCountryVC: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var delegate: ChooseCountryDelegate?
    
    var CountryList = [Select_Country_List_Struct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        self.getCountryList()
    }
    
    func getCountryList() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.VENDOR_COUNTY_LIST_COLOR_CODE, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                //success == "true"
                if success == "true"
                {
                    self.CountryList.removeAll()
                    for i in 0..<json["countryColorCodeList"].count
                    {
                        let countryName =  json["countryColorCodeList"][i]["countryName"].stringValue
                        let countryColor =  json["countryColorCodeList"][i]["colorCode"].stringValue
                        let flagName = json["countryColorCodeList"][i]["flag"].stringValue
                        
                        self.CountryList.append(Select_Country_List_Struct.init(countryName: countryName, colorCode: countryColor, flagName: flagName))
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
    
}
extension ChooseCountryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CountryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as! countryCell
        let info = self.CountryList[indexPath.row]
        cell.cellLbl.text = info.countryName
        //var apiUrl = FLAG_BASE_URL + "/\(info.flagName)"
        cell.cellImg.sd_setImage(with: URL(string: FLAG_BASE_URL + "/\(info.flagName)"), completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let info = self.CountryList[indexPath.row]
        UserDefaults.standard.set(info.colorCode, forKey: USER_DEFAULTS_KEYS.COUNTRY_COLOR_CODE)
        UserDefaults.standard.set(info.countryName, forKey: USER_DEFAULTS_KEYS.SELECTED_COUNTRY)
        UserDefaults.standard.set(info.flagName, forKey: USER_DEFAULTS_KEYS.SELECTED_FLAG)
        
        countryColorCode = info.colorCode
        
        if UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.VENDOR_SIGNUP_TOKEN) != nil {
            delegate?.onSelectCountry(country: info)
            
            self.navigationController?.popViewController(animated: true)
        } else {
            let userStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = userStoryboard.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            UIApplication.shared.delegate!.window!!.rootViewController = viewController
        }
        
    }
    
    
}

extension ChooseCountryVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.getCountryList()
        } else {
//            self.CountryList = self.CountryList.filter({ (item) -> Bool in
//                return item.countryName.contains(searchText)
//            })
            
            self.CountryList = self.CountryList.sorted(by: { (i1, i2) -> Bool in
                return i1.countryName.contains(searchText)
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        print("searchText \(searchText)")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(String(describing: searchBar.text))")
    }
}
