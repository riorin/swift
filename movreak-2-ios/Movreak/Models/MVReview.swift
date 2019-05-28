//
//  MVReview.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/12/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class MVReview: Object, Mappable {
    
    dynamic var reviewID: Int64 = 0
    dynamic var replyToID: String?
    dynamic var replyToUser: String?
    var userProfileID = RealmOptional<Int64>()
    dynamic var reviewContent: String?
    dynamic var submittedDate: Date?
    var thumbs = RealmOptional<Int>()
    dynamic var lastModifiedDate: Date?
    var doesLikeThis = RealmOptional<Bool>()
    var likesCount = RealmOptional<Int>()
    var likes = List<MVReviewLike>()
    var repliesCount = RealmOptional<Int>()
    var replies = List<MVReview>()
    dynamic var movie: MVMovie?
    dynamic var user: MVUser?
    
    dynamic var isDraft: Bool = false
    
    dynamic var submitCity: String?
    dynamic var submitCountryCode: String?
    dynamic var submitLocation: String?
    var submitLat = RealmOptional<Double>()
    var submitLong = RealmOptional<Double>()
    dynamic var sharedWithAcc: String?
    
    override class func primaryKey() -> String? {
        return "reviewID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        reviewID <- (map["ReviewID"], Int64Transform())
        replyToID <- map["ReplyToID"]
        replyToUser <- map["ReplyToUser"]
        userProfileID <- (map["UserProfileID"], RealmOptionalTransform<Int64>())
        reviewContent <- map["ReviewContent"]
        submittedDate <- (map["SubmittedDate"], DateTransform())
        thumbs <- (map["Thumbs"], RealmOptionalTransform<Int>())
        lastModifiedDate <- (map["LastModifiedDate"], DateTransform())
        likesCount <- (map["LikesCount"], RealmOptionalTransform<Int>())
        repliesCount <- (map["RepliesCount"], RealmOptionalTransform<Int>())
        doesLikeThis <- (map["DoesLikeThis"], RealmOptionalTransform<Bool>())
        likes <- (map["Likes"], ListTransform<MVReviewLike>())
        replies <- (map["Replies"], ListTransform<MVReview>())
        movie <- map["Movie"]
        user <- map["User"]
        
        submitCity <- map["SubmitCity"]
        submitCountryCode <- map["SubmitCountryCode"]
        submitLocation <- map["SubmitLocation"]
        submitCity <- map["SubmitCity"]
        submitLat <- (map["SubmitLat"], RealmOptionalTransform<Double>())
        submitLong <- (map["SubmitLong"], RealmOptionalTransform<Double>())
        sharedWithAcc <- map["SharedWithAcc"]
    }
    
    func asDictionary() -> [String : Any] {
        var parameters: [String: Any] = [:]
        
        if let movie = movie {
            parameters["Movie"] = movie.meta()
        }
        if let replyToID = replyToID {
            parameters["ReplyToID"] = replyToID
        }
        if let replyToUser = replyToUser {
            parameters["ReplyToUser"] = replyToUser
        }
        if let review = reviewContent {
            parameters["ReviewContent"] = review
        }
        if let shared = sharedWithAcc {
            parameters["SharedWithAcc"] = shared
        }
        if let city = submitCity {
            parameters["SubmitCity"] = city
        }
        if let countryCode = submitCountryCode {
            parameters["SubmitCountryCode"] = countryCode
        }
        if let location = submitLocation {
            parameters["SubmitLocation"] = location
        }
        if let lat = submitLat.value {
            parameters["SubmitLat"] = "\(lat)"
        }
        if let lng = submitLong.value {
            parameters["SubmitLong"] = "\(lng)"
        }
        parameters["SubmittedDate"] = Date().format(with: "yyyy-MM-dd'T'HH:mm:ss'Z'")
        if let user = user {
            parameters["UserProfile"] = user.meta()
        }
        if let thumbs = thumbs.value {
            parameters["Thumbs"] = thumbs
        }
        
        return parameters
    }
}
