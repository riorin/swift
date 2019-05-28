//
//  MVMovieList.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/19/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class MVMovieList: Object, Mappable {

    dynamic var listID: String = ""
    dynamic var createdBy: String?
    dynamic var createdDate: Date?
    dynamic var descripción: String?
    var favoriteCount = RealmOptional<Int>()
    var itemCount = RealmOptional<Int>()
    var movies = List<MVMovie>()
    dynamic var name: String?
    dynamic var posterUrl: String?
    
    public override static func primaryKey() -> String? {
        return "listID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        listID <- map["ListId"]
        if listID.isEmpty { listID <- map["ItemID"] }
        createdBy <- map["CreatedBy"]
        createdDate <- (map["CreatedDate"], DateTransform())
        descripción <- map["Description"]
        favoriteCount <- (map["FavoriteCount"], RealmOptionalTransform<Int>())
        itemCount <- (map["ItemCount"], RealmOptionalTransform<Int>())
        movies <- (map["Items"], ListTransform<MVMovie>())
        name <- map["Name"]
        if name == nil { name <- map["Title"] }
        posterUrl <- map["PosterUrl"]
        
    }
}
