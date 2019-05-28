//
//  MVResponse.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class MVResponse: NSObject, Mappable {
    
    var status: String?
    var message: String?
    var relatedObjectID: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        status <- map["Status"]
        message <- map["Message"]
        relatedObjectID <- map["RelatedObjectID"]
    }
}
