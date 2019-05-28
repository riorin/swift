//
//  Movie.swift
//  TableViewDemo
//
//  Created by Bayu Yasaputro on 27/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object, Codable {
    
    @objc dynamic var movieId: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var posterPath: String = ""
    @objc dynamic var releaseDate: Date = Date(timeIntervalSince1970: 0)
    
    @objc dynamic var backdropPath: String = ""
    @objc dynamic var homepage: String = ""
    
    override class func primaryKey() -> String? {
        return "movieId"
    }
    
    enum CodingKeys: String, CodingKey {
        case movieId = "id"
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        
        case backdropPath = "backdrop_Path"
        case homepage
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        movieId = try values.decode(Int.self, forKey: .movieId)
        title = try values.decode(String.self, forKey: .title)
        overview = try values.decode(String.self, forKey: .overview) 
        posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath) ?? ""

        let dateString = try values.decode(String.self, forKey: .releaseDate)
        releaseDate = dateString.date(with: "yyyy-MM-dd")
    }
}







