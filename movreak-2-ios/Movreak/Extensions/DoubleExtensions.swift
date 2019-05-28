//
//  DoubleExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/25/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation

extension Double {
    
    var distanceString: String {
        var text = ""
        if self < 1000 {
            let numberString = String(format: "%.0f", self)
            text = "\(numberString) m"
        }
        else {
            let number = self / 1000
            let numberString = String(format: "%.2f", number)
            text = "\(numberString) km"
        }
        return text
    }
}
