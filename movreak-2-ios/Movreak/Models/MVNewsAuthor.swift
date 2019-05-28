//
//	MVAuthor.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import RealmSwift
import ObjectMapper

class MVNewsAuthor: Object, Mappable {
    
    dynamic var id: Int64 = 0
	dynamic var descripción: String?
	dynamic var firstName: String?
	dynamic var lastName: String?
	dynamic var name: String?
	dynamic var nickname: String?
	dynamic var slug: String?
	dynamic var url: String?

    public override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
		descripción <- map["description"]
		firstName <- map["first_name"]
		lastName <- map["last_name"]
		name <- map["name"]
		nickname <- map["nickname"]
		slug <- map["slug"]
		url <- map["url"]
		
	}
}
