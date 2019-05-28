//
//  MVPopularMovie.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/14/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class MVPopularMovie: Object, Mappable {

    dynamic var movie: MVMovie?
    var reviewCount = RealmOptional<Int>()
    var score = RealmOptional<Double>()
    dynamic var unit: String?
    var watched = RealmOptional<Bool>()
    var watchingCount = RealmOptional<Int>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        movie <- map["Movie"]
        reviewCount <- (map["ReviewCount"], RealmOptionalTransform<Int>())
        score <- (map["Score"], RealmOptionalTransform<Double>())
        unit <- map["Unit"]
        watched <- (map["Watched"], RealmOptionalTransform<Bool>())
        watchingCount <- (map["WatchingCount"], RealmOptionalTransform<Int>())
    }
}
