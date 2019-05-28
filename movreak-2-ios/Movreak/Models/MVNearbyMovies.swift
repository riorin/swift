//
//  MVNearbyMovies.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 7/5/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift

class MVNearbyMovies: Object {
    
    var movies = List<MVMovie>()
}

extension MVNearbyMovies {
    
    static func nearby() -> MVNearbyMovies {
        
        let realm = try! Realm()
        if let recent = realm.objects(MVNearbyMovies.self).first {
            return recent
        }
        else {
            let recent = MVNearbyMovies()
            try! realm.write { realm.add(recent) }
            return recent
        }
    }
    
    func add(movies: [MVMovie]) {
        
        let realm = try! Realm()
        try! realm.write {
            
            self.movies.removeAll()
            for movie in movies {
                realm.add(movie, update: true)
                self.movies.append(movie)
            }
        }
    }
}
