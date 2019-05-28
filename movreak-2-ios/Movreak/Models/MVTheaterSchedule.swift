//
//	MVTheaterSchedule.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


class MVTheaterSchedule: Object, Mappable {
    
    dynamic var scheduleID: String = ""
	dynamic var locationCity: String?
	var movies = List<MVScheduledMovie>()
	dynamic var showDate: Date?
	dynamic var theater: MVTheater?


    public override static func primaryKey() -> String? {
        return "scheduleID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        scheduleID <- map["ScheduleID"]
		locationCity <- map["LocationCity"]
		movies <- (map["Movies"], ListTransform<MVScheduledMovie>())
		showDate <- (map["ShowDate"], DateTransform())
		theater <- map["Theater"]
	}
}
