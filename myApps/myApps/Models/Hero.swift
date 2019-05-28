//
//  Hero.swift
//  myApps
//
//  Created by Rio Rinaldi on 21/05/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import Foundation

struct hero:Decodable {
    let localized_name: String
    let primary_attr: String
    let attack_type: String
    let legs: Int
    let image: String
}
