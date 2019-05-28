//
//	MVLink.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


class MVLink: Object, Mappable {
    
    dynamic var itemID: Int = 0
    dynamic var createdDate: Date?
    dynamic var descripción: String?
    dynamic var launchUrl: String?
    dynamic var launchType: String?
    dynamic var title: String?
    dynamic var subTitle: String?
    
    public override static func primaryKey() -> String? {
        return "itemID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
		itemID <- map["ItemID"]
		createdDate <- (map["CreatedDate"], DateTransform())
		descripción <- map["Description"]
		launchUrl <- map["LaunchUrl"]
		launchType <- map["LaunchType"]
		title <- map["Title"]
		subTitle <- map["SubTitle"]
	}
}
