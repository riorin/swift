//
//  Movies.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 04/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation

struct Movies: Codable {
    
    var page: Int
    var total_results: Int
    var total_pages: Int
    var results: [Movie]
}
