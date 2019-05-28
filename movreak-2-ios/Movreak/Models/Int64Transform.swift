//
//  Int64Transform.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/8/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import ObjectMapper


class Int64Transform: TransformType {
    typealias Object = Int64
    typealias JSON = Any
    
    func transformFromJSON(_ value: Any?) -> Int64? {
        if let value = value as? Int64 {
            return value
        }
        else if let value = value as? String {
            return Int64(value)
        }
        else if let value = value as? Double {
            return Int64(value)
        }
        else if let value = value as? Bool {
            return Int64(value ? 1 : 0)
        }
        
        return nil
    }
    
    func transformToJSON(_ value: Int64?) -> Any? {
        return value
    }
}
