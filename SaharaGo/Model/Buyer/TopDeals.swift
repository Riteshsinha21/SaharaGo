//
//  TopDeals.swift
//  SaharaGo
//
//  Created by Ashish Nimbria on 12/23/20.
//

import Foundation

struct TopDeals: Decodable {
    var productList: [TopDealsProductList]?
    
    var success: Bool?
}

struct TopDealsProductList: Decodable {
    var productID, itemID, name, categoryID: String?
    var dimension: String?
    var currency: String?
    var actualPrice: Int?
    var discountType: String?
    var discountValue, discountedPrice, stock: Int?
    var metaData: TopDealsMetaData?
    var rating: Int?
    var success: Bool?
    var image: String?

    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case itemID = "itemId"
        case name
        case image
        case categoryID = "categoryId"
        case dimension, currency, actualPrice, discountType, discountValue, discountedPrice, stock, metaData, rating, success
    }
}

struct TopDealsMetaData: Decodable {
    var metaDataDescription: String?
    var images: [String]?

    enum CodingKeys: String, CodingKey {
        case metaDataDescription = "description"
        case images
    }
}
