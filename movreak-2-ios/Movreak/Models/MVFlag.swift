//
//  MVFlag.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

enum FlagType: String {
    case spam = "SPAM"
    case spoiler = "SPOILER"
}

class MVFlag: NSObject {

    var contentOwnerID: Int64?
    var flagFromCity: String?
    var flagType: FlagType?
    let flaggedContent = "MovieUserReview"
    var flaggedContentID: Int64?
    var user: MVUser?
    
    func asDictionary() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        if let contentOwnerID = contentOwnerID {
            parameters["ContentOwnerID"] = "\(contentOwnerID)"
        }
        if let flagFromCity = flagFromCity {
            parameters["FlagFromCity"] = flagFromCity
        }
        parameters["FlagDate"] = Date().format(with: "yyyy-MM-dd'T'HH:mm:ss'Z'")
        if let flagType = flagType {
            parameters["FlagType"] = flagType.rawValue
        }
        parameters["FlaggedContent"] = flaggedContent
        if let flaggedContentID = flaggedContentID {
            parameters["FlaggedContentID"] = "\(flaggedContentID)"
        }
        if let user = user {
            parameters["UserProfile"] = user.meta()
        }
        
        return parameters
    }
}
