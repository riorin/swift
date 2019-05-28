//
//  MVMovieInfo.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/3/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class MVMovieInfo: NSObject, Mappable {
    
    var label: String?
    var value: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        label <- map["Label"]
        value <- map["Value"]
    }
}
