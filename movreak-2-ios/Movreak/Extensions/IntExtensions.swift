//
//  IntExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/2/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation

extension Int {
    
    var durationString: String {
        
        let hours: Int = self / 60
        let minutes: Int = self % 60
        
        var durationString = ""
        if hours > 0 { durationString = "\(hours)h" }
        if minutes > 0 {
            if durationString.characters.count > 0 {
                durationString = "\(durationString) \(minutes)min"
            }
            else {
                durationString = "\(minutes)min"
            }
        }
        
        return durationString
    }
}
