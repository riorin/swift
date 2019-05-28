//
//  DateTransform.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/12/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper

class DateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Any
    
    func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt))
        }
        
        if let timeStr = value as? String {
            return timeStr.date()
        }
        
        return nil
    }
    
    func transformToJSON(_ value: Date?) -> Any? {
        if let date = value {
            return date.format(with: kDefaultDateFormat)
        }
        return nil
    }
}
