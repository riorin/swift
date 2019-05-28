//
//	MVTag.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


class MVNewsTag: Object, Mappable {

    dynamic var id: Int64 = 0
	dynamic var descripción: String?
	var postCount = RealmOptional<Int>()
	dynamic var slug: String?
	dynamic var title: String?
    
    public override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        descripción <- map["description"]
		id <- map["id"]
		postCount <- (map["post_count"], RealmOptionalTransform<Int>())
		slug <- map["slug"]
		title <- map["title"]
		
	}
}
