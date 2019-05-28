//
//  StringTransform.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/22/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper


class StringTransform: TransformType {
    typealias Object = String
    typealias JSON = Any
    
    func transformFromJSON(_ value: Any?) -> String? {
        if let value = value {
            return "\(value)"
        }
        
        return nil
    }
    
    func transformToJSON(_ value: String?) -> Any? {
        return value
    }
}
