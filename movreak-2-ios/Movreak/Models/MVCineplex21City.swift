//
//  MVCineplex21City.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 9/9/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class MVCineplex21City: NSObject, Mappable {
    
    var name: String = ""
    var cityId: String = ""
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        name <- map["name"]
        cityId <- map["id"]
    }
}
