//
//  PathPhoto.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift

class PathPhoto: Object {
    
    dynamic var url: String = ""
    let width = RealmOptional<Double>()
    let height = RealmOptional<Double>()
    
    override static func primaryKey() -> String? {
        return "url"
    }
}
