//
//  ReviewDraft.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/22/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift

class ReviewDraft: Object {

    dynamic var reviewContent: String = ""
    dynamic var thumbs: Int = 0
    dynamic var submitCity: String?
    dynamic var submitCountryCode: String?
    dynamic var submitLocation: String?
    let submitLat = RealmOptional<Double>()
    let submitLong = RealmOptional<Double>()
    dynamic var movie: MovieMetadata?
    dynamic var user: UserMetadata?
    dynamic var sharedWithAcc: String?
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        dictionary["ReviewContent"] = reviewContent
        dictionary["Thumbs"] = thumbs
        if let submitCity = submitCity {
            dictionary["SubmitCity"] = submitCity
        }
        if let submitCountryCode = submitCountryCode {
            dictionary["SubmitCountryCode"] = submitCountryCode
        }
        if let submitLocation = submitLocation {
            dictionary["SubmitLocation"] = submitLocation
        }
        if let lat = submitLat.value {
            dictionary["SubmitLat"] = lat
        }
        if let long = submitLong.value {
            dictionary["SubmitLong"] = long
        }
        if let metadata = movie?.metadata {
            dictionary["Movie"] = metadata.toDictionary()
        }
        if let metadata = user?.metadata {
            dictionary["UserProfile"] = metadata.toDictionary()
        }
        if let sharedWithAcc = sharedWithAcc {
            dictionary["SharedWithAcc"] = sharedWithAcc
        }
        
        return dictionary
    }
}

class Metadata: Object {
    dynamic var uri: String = ""
    
    func toDictionary() -> [String: Any] {
        return [
            "__metadata": [
                "uri": uri
            ]
        ]
    }
}

class UserMetadata: Object {
    dynamic var metadata: Metadata?
}

class MovieMetadata: Object {
    dynamic var metadata: Metadata?
    dynamic var movieID: Int64 = 0
    dynamic var title: String = ""
    dynamic var rottenTomatoesID: String = ""
}

