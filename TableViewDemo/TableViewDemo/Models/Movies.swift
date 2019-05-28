//
//  Movies.swift
//  TableViewDemo
//
//  Created by Bayu Yasaputro on 27/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation

struct Movies: Codable {
    
    var page: Int
    var total_results: Int
    var total_pages: Int
    var results: [Movie]
}
