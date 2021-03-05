//
//  OrdersModel.swift
//  SaharaGo
//
//  Created by Ritesh on 04/01/21.
//

import Foundation
import UIKit

struct current_order_Address_main_struct {
    var orderState: String = ""
    var totalPrice: String = ""
    var orderId: String = ""
    
    var country:String = ""
    var state:String = ""
    var lastName:String = ""
    var firstName:String = ""
    var city :String = ""
    var phone :String = ""
    var zipcode:String = ""
    var streetAddress :String = ""
    var landmark :String = ""
    //var addressMetaData :current_order_Address_struct = current_order_Address_struct()
    var cartMetaData :[current_order_cartData_struct] = [current_order_cartData_struct]()
}

//struct current_order_Address_struct {
//    var country:String = ""
//    var state:String = ""
//    var lastName:String = ""
//    var firstName:String = ""
//    var city :String = ""
//    var phone :String = ""
//    var zipcode:String = ""
//    var streetAddress :String = ""
//    var landmark :String = ""
//}

struct current_order_cartData_struct {
    var itemId:String = ""
    var productId:String = ""
    var price:String = ""
    var discountedPrice:String = ""
    var name :String = ""
    var currency :String = ""
    var quantity:String = ""
    var discountPercent :String = ""
    var stock :String = ""
    var totalPrice :String = ""
    var isRated :Bool = false
    var metaData :current_order_metaData_struct = current_order_metaData_struct()
    var rating:Double = 0.0
    var userRating:Double = 0.0
    var userReview :String = ""
    
}

struct current_order_metaData_struct {
    var images = [Any]()
    var description :String = ""
}

