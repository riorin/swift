//
//  Movie.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 04/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object, Codable {
    
    @objc dynamic var movieId: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var posterPath: String = ""
    @objc dynamic var backdropPath: String = ""
    @objc dynamic var homepage: String = ""
    @objc dynamic var releaseDate: Date = Date(timeIntervalSince1970: 0)
    
    override class func primaryKey() -> String? {
        return "movieId"
    }
    
    enum CodingKeys: String, CodingKey {
        
        case movieId = "id"
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case homepage
        case releaseDate = "release_date"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        
        let value = try decoder.container(keyedBy: CodingKeys.self)
        movieId = try value.decodeIfPresent(Int.self, forKey: .movieId) ?? 0
        
        let realm = try! Realm()
        let movie = realm.object(ofType: Movie.self, forPrimaryKey: movieId)
        
        title = try value.decodeIfPresent(String.self, forKey: .title) ?? movie?.title ?? ""
        overview = try value.decodeIfPresent(String.self, forKey: .overview) ??  movie?.overview ?? ""
        posterPath = try value.decodeIfPresent(String.self, forKey: .posterPath) ??  movie?.posterPath ?? ""
        backdropPath = try value.decodeIfPresent(String.self, forKey: .backdropPath) ??  movie?.backdropPath ?? ""
        homepage = try value.decodeIfPresent(String.self, forKey: .homepage) ??  movie?.homepage ?? ""
        
        if let dateString = try value.decodeIfPresent(String.self, forKey: .releaseDate) {
            releaseDate = dateString.date(with: "yyyy-MM-dd")
        }
        else {
            releaseDate = movie?.releaseDate ?? Date(timeIntervalSince1970: 0)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(movieId, forKey: .movieId)
        try values.encode(title, forKey: .title)
        try values.encode(overview, forKey: .overview)
        try values.encode(posterPath, forKey: .posterPath)
        try values.encode(backdropPath, forKey: .backdropPath)
        try values.encode(homepage, forKey: .homepage)
        try values.encode(releaseDate.string(with: "yyyy-MM-dd"), forKey: .releaseDate)
    }
}
