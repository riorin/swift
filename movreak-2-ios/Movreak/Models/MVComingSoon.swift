//
//  MVComingSoon.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/15/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class MVComingSoon: NSObject, Mappable {

    var releaseWeek: String?
    var movies: [MVMovie] = []
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        releaseWeek <- map["ReleaseWeek"]
        movies <- map["Movies"]
    }
    
    init(object: MVComingSoon) {
        super.init()
        
        self.releaseWeek = object.releaseWeek
    }
}
