//
//  PopupVC.swift
//  SaharaGo
//
//  Created by Ritesh on 17/01/21.
//

import UIKit

class PopupVC: UIViewController {

    @IBOutlet var msgLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    
    var titleStr = ""
    var msgStr = ""
    var completionHandlerCallback:((String) ->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleLbl.text = self.titleStr
        self.msgLbl.text = self.msgStr
    }
    
    @IBAction func crossAction(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesAction(_ sender: Any) {
        if self.completionHandlerCallback != nil {
            self.completionHandlerCallback!("yes")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func noAction(_ sender: Any) {
        if self.completionHandlerCallback != nil {
            self.completionHandlerCallback!("no")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    

}
