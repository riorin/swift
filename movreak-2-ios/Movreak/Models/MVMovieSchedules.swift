//
//	MVMovieSchedules.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper

class MVMovieSchedules: NSObject, Mappable {

	var schedules: [MVMovieSchedule] = []
	var state: MVScheduleState?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
    
        schedules <- map["Schedules"]
        state <- map["State"]
    }
}
