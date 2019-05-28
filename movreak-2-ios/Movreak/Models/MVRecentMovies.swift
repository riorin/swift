//
//  MVRecentMovies.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 7/5/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift

let kRecentMoviesCount = 10

class MVRecentMovies: Object {
    
    var movies = List<MVMovie>()
}

extension MVRecentMovies {
    
    static func recent() -> MVRecentMovies {
        
        let realm = try! Realm()
        if let recent = realm.objects(MVRecentMovies.self).first {
            return recent
        }
        else {
            let recent = MVRecentMovies()
            try! realm.write { realm.add(recent) }
            return recent
        }
    }
    
    func add(movie: MVMovie) {
        
        let realm = try! Realm()
        try! realm.write {
            
            if let index = movies.index(matching: "movieID = %@", movie.movieID) {
                self.movies.move(from: index, to: 0)
            }
            else {
                
                realm.add(movie, update: true)
                self.movies.insert(movie, at: 0)
                
                if self.movies.count > kRecentMoviesCount {
                    self.movies.removeLast()
                }
            }
        }
    }
}
