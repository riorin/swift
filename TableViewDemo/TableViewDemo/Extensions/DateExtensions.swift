//
//  DateExtensions.swift
//  TableViewDemo
//
//  Created by Bayu Yasaputro on 27/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation

extension Date {
    
    func string(with format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
}
