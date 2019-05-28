//
//  MVMovieDetail.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/3/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class MVMovieDetail: NSObject, Mappable {
    
    var odatametadata: String?
    var movie: MVMovie?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        odatametadata <- map["odata.metadata"]
        movie <- map["value.0"]
    }
}
