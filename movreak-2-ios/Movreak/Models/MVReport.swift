//
//  MVFlag.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

enum FlagType {
    case spam
    case spoiler
    
    var description: String {
        switch self {
        case .spam:
            return "SPAM"
            
        case .spoiler:
            return "SPOILER"
        }
    }
}

class MVFlag: NSObject {

    var ContentOwnerID: String?
    var FlagFromCity: String?
    var FlagDate: String?
    var FlagType: ReportType?
    var FlaggedContent" : "MovieUserReview",
    var user: MVUser?
    var FlaggedContentID" : "10970"
}
