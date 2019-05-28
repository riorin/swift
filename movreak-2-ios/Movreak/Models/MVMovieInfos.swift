//
//  MVMovieInfos.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/3/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class MVMovieInfos: NSObject, Mappable {

    var locale: String?
    var properties: [MVMovieInfo] = []
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        locale <- map["Locale"]
        properties <- map["Properties"]
    }
    
    var movieInfos: [MVMovieInfo] {
        
        let movieInfos: [MVMovieInfo] = properties.filter({ (property) -> Bool in
            var filter = true
            if let label = property.label {
                filter = !kCreditLabels.contains(label)
            }
            return filter
        })
        return movieInfos
    }
    
    var casts: [MVMovieInfo] {
        
        let casts: [MVMovieInfo] = properties.filter({ (property) -> Bool in
            var filter = false
            if let label = property.label {
                filter = kCreditLabels.contains(label)
            }
            return filter
        })
        return casts
    }
}
