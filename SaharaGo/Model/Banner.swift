//
//  Banner.swift
//  SaharaGo
//
//  Created by Ashish Nimbria on 12/31/20.
//

import Foundation

struct GetBannerResponse: Decodable {
    var bannerList: [String]?
    var success: Bool?
}
