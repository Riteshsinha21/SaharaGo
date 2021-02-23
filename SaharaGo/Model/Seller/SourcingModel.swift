//
//  SourcingModel.swift
//  SaharaGo
//
//  Created by Ritesh on 15/12/20.
//

import Foundation
import UIKit

struct categoryListStruct {
    var id:String = ""
    var status:String = ""
    var name:String = ""
    var description:String = ""
    var image :String = ""
    var isSubCategoryAvailable:Bool = false
    var parentCategory :String = ""
    var comment :String = ""
}

struct categoryProductListStruct {
    var categoryId:String = ""
    var currency:String = ""
    var description:String = ""
    var category:String = ""
    var stock:String = ""
    var vendorName:String = ""
    var productId :String = ""
    var itemId :String = ""
    var price:String = ""
    var discountedPrice:String = ""
    var discountPercent:String = ""
    var rating:String = ""
    var name :String = ""
    //var images :String = ""
    var images: [String]?
    var actualPrice :String = ""
    var wishlisted:Bool = false
    
}



