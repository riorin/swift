//
//  DoubleTransform.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import ObjectMapper


class DoubleTransform: TransformType {
    typealias Object = Double
    typealias JSON = Any
    
    func transformFromJSON(_ value: Any?) -> Double? {
        if let value = value as? Int {
            return Double(value)
        }
        else if let value = value as? String {
            return Double(value)
        }
        else if let value = value as? Double {
            return value
        }
        else if let value = value as? Bool {
            return Double(value ? 1 : 0)
        }
        
        return nil
    }
    
    func transformToJSON(_ value: Double?) -> Any? {
        return value
    }
}
