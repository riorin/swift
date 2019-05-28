//
//  MVUser.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/12/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper


class MVUser: Object, Mappable {

    dynamic var userProfileID: Int64 = 0
    dynamic var about: String?
    dynamic var authProvider: String?
    dynamic var bigPhotoUrl: String?
    dynamic var coverImageUrl: String?
    dynamic var createdDate: Date?
    dynamic var displayName: String?
    dynamic var email: String?
    dynamic var facebookID: String?
    dynamic var gender: String?
    dynamic var photoUrl: String?
    dynamic var preferedCity: String?
    dynamic var preferedCountry: String?
    var preferedTheater = RealmOptional<Int64>()
    dynamic var preferedTheaterName: String?
    var reviewsCount = RealmOptional<Int>()
    dynamic var twitterUserName: String?
    dynamic var userIdentifier: String?
    dynamic var userName: String?
    var watchedMoviesCount = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "userProfileID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        userProfileID <- map["UserProfileID"]
        about <- map["About"]; if about == nil { about <- map["AboutMe"] }
        authProvider <- map["AuthProvider"]
        bigPhotoUrl <- map["BigPhotoUrl"]
        coverImageUrl <- map["CoverImageUrl"]
        createdDate <- (map["CreatedDate"], DateTransform())
        displayName <- map["DisplayName"]
        email <- map["Email"]
        facebookID <- map["FacebookID"]
        gender <- map["Gender"]
        photoUrl <- map["PhotoUrl"]
        preferedCity <- map["PreferedCity"]
        preferedCountry <- map["PreferedCountry"]
        preferedTheater <- (map["PreferedTheater"], RealmOptionalTransform<Int64>())
        preferedTheaterName <- map["PreferedTheaterName"]
        reviewsCount <- (map["ReviewsCount"], RealmOptionalTransform<Int>())
        twitterUserName <- map["TwitterUserName"]
        userIdentifier <- map["UserIdentifier"]
        userName <- map["UserName"]
        watchedMoviesCount <- (map["WatchedMoviesCount"], RealmOptionalTransform<Int>())
        
//        let r = try! Realm()
//        if let object = r.object(ofType: MVUser.self, forPrimaryKey: userProfileID) {
//            for property in objectSchema.properties {
//                if property == objectSchema.primaryKeyProperty { continue }
//                if self.value(forKey: property.name) == nil {
//                    self.setValue(object.value(forKey: property.name), forKey: property.name)
//                }
//            }
//        }
    }
}

extension MVUser {
    
    static func defaultPhoto() -> UIImage {
        return kDefaultProfileImage
    }
    
    static func defaultCoverImage() -> UIImage {
        return kDefaultCoverProfileImage
    }
    
    func meta() -> [String: Any] {
        return [
            "__metadata": [
                "uri": "/UserProfiles(\(userProfileID)L)"
            ]
        ]
    }
}
