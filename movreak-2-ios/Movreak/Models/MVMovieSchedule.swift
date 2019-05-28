//
//	MVMovieSchedule.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper

class MVMovieSchedule: Object, Mappable {
    
    dynamic var scheduleID: String = ""
    dynamic var locationCity: String?
    dynamic var showDate: Date?
	dynamic var movie: MVMovie?
	var theaters = List<MVScheduledTheater>()
    
    public override static func primaryKey() -> String? {
        return "scheduleID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        scheduleID <- map["ScheduleID"]
        locationCity <- map["LocationCity"]
        showDate <- (map["ShowDate"], DateTransform())
        theaters <- (map["Theaters"], ListTransform<MVScheduledTheater>())
        movie <- map["Movie"]
    }
}
