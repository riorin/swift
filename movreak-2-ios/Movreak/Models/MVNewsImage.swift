//
//  MVNewsImage.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class MVNewsImage: Object, Mappable {
    
    dynamic var url: String?
    dynamic var title: String?
    
    public override static func primaryKey() -> String? {
        return "url"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        url <- map["url"]
        title <- map["title"]
    }

}
