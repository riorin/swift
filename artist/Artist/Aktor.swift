//
//  Aktor.swift
//  Artist
//
//  Created by Rio Rinaldi on 17/07/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import Foundation

class Actors: Codable {
    let actors: [Actor]
    
    init(actors: [Actor]){
        self.actors = actors
    }
}

class Actor: Codable {
    let name: String
    let dob: String
    let image: String
    
    init(name: String, dob: String, image:String) {
        self.name = name
        self.dob = dob
        self.image = image
    }
}




