//
//  EditProfileVC.swift
//  SaharaGo
//
//  Created by Ritesh on 07/12/20.
//

import UIKit

class EditProfileVC: UIViewController {
    
    @IBOutlet var countryTxt: UITextField!
    @IBOutlet var mailtxt: UITextField!
    @IBOutlet var lastNameTxt: UITextField!
    @IBOutlet var firstNameTxt: UITextField!
    
    var profileDetail = profileDetail_Struct()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraAction(_ sender: Any) {
    }
    
    
}
