//
//  MVCity.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/3/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class MVCity: Object, Mappable {

    dynamic var cityID: Int64 = 0
    dynamic var cityName: String?
    dynamic var countryCode: String?
    dynamic var countryName: String?

    override static func primaryKey() -> String? {
        return "cityID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        cityID <- map["CityID"]
        cityName <- map["CityName"]
        countryCode <- map["CountryCode"]
        countryName <- map["CountryName"]
    }
}
