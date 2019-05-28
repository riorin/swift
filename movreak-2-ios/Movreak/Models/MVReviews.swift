//
//  MVReviews.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/12/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class MVReviews: NSObject, Mappable {

    var reviews: [MVReview] = []
    var highestReviewer: String = ""
    var reviewCount: Int = 0
    var totalReview: Int = 0
    var averageThumbs: Double = 0
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        reviews <- map["UserReviews"]
        highestReviewer <- map["ReviewStat.HighestReviewer"]
        reviewCount <- map["ReviewStat.ReviewCount"]
        totalReview <- map["ReviewStat.TotalReview"]
        averageThumbs <- map["ReviewStat.AverageThumbs"]
    }
}
