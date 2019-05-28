//
//	MVScheduleState.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper

class MVScheduleState: NSObject, Mappable {

	var message: String?
	var status: String?

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        message <- map["Message"]
        status <- map["Status"]
    }
}
