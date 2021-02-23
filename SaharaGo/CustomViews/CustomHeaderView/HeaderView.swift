//
//  HeaderView.swift
//  KidyView
//
//  Created by Demo on 06/02/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import Foundation
import UIKit

class HeaderView: UIView {
    
    @IBOutlet weak var titlelabel: UILabel!
    
    @IBOutlet weak var rightBtn: UIButton!
    var view : UIView?
    
    func xibSetup() {
        view = loadViewFromNib()
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    
}
