//
//  MVReviewLike.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/12/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class MVReviewLike: Object, Mappable {
    
    dynamic var userProfileID: Int64 = 0
    dynamic var submittedDate: Date?
    dynamic var reviewContent: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        userProfileID <- map["UserProfileID"]
        submittedDate <- (map["SubmittedDate"], DateTransform())
        reviewContent <- map["ReviewContent"]
    }
}
