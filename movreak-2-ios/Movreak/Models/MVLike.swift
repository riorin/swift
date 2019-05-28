//
//  MVLike.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class MVLike: NSObject {

    var contentOwnerID: Int64?
    let likedContent: String = "MovieUserReview"
    var likedContentID: Int64?
    var likerUserIdentifier: String?
    var likeFromCity: String?
    var user: MVUser?
    
    func asDictionary() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        if let contentOwnerID = contentOwnerID {
            parameters["ContentOwnerID"] = "\(contentOwnerID)"
        }
        parameters["LikedContent"] = likedContent
        if let likedContentID = likedContentID {
            parameters["LikedContentID"] = "\(likedContentID)"
        }
        if let likerUserIdentifier = likerUserIdentifier {
            parameters["LikerUserIdentifier"] = likerUserIdentifier
        }
        if let likeFromCity = likeFromCity {
            parameters["LikeFromCity"] = likeFromCity
        }
        if let user = user {
            parameters["UserProfile"] = user.meta()
        }
        
        return parameters
    }
}
