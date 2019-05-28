//
//  PathProfile.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class PathProfile: Object {
    
    dynamic var userId: String = ""
    dynamic var accessToken: String?
    dynamic var email: String?
    dynamic var password: String?
    
    dynamic var oauthToken: String?
    dynamic var messagingUserId: String?
    
    dynamic var username: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var gender: String?
    
    dynamic var smallPhoto: PathPhoto?
    dynamic var mediumPhoto: PathPhoto?
    dynamic var originalPhoto: PathPhoto?
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    class func from(json: JSON) -> PathProfile {
        
        let pathProfile = PathProfile()
        
        pathProfile.userId = json["id"].stringValue
        
        pathProfile.oauthToken = json["oauth_token"].string
        pathProfile.messagingUserId = json["messaging_user_id"].string
        
        pathProfile.username = json["username"].string
        pathProfile.firstName = json["first_name"].string
        pathProfile.lastName = json["last_name"].string
        pathProfile.gender = json["gender"].string
        
        let smallPhoto = PathPhoto()
        smallPhoto.url = "\(json["photo"]["url"].stringValue)/\(json["photo"]["ios"]["1x"]["file"].stringValue)"
        smallPhoto.width.value = json["photo"]["ios"]["1x"]["width"].double
        smallPhoto.height.value = json["photo"]["ios"]["1x"]["height"].double
        pathProfile.smallPhoto = smallPhoto
        
        let mediumPhoto = PathPhoto()
        mediumPhoto.url = "\(json["photo"]["url"].stringValue)/\(json["photo"]["ios"]["2x"]["file"].stringValue)"
        mediumPhoto.width.value = json["photo"]["ios"]["2x"]["width"].double
        mediumPhoto.height.value = json["photo"]["ios"]["2x"]["height"].double
        pathProfile.mediumPhoto = mediumPhoto
        
        let originalPhoto = PathPhoto()
        originalPhoto.url = "\(json["photo"]["url"].stringValue)/\(json["photo"]["original"]["file"].stringValue)"
        originalPhoto.width.value = json["photo"]["original"]["width"].double
        originalPhoto.height.value = json["photo"]["original"]["height"].double
        pathProfile.originalPhoto = originalPhoto
        
        return pathProfile
    }
}
