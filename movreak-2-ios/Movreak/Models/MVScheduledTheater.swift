//
//	MVScheduledTheater.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper

class MVScheduledTheater: Object, Mappable {
    
    dynamic var scheduledTheaterID: String = ""
    dynamic var blitzCinType: String?
    dynamic var movieFormat: String?
    dynamic var showDate: Date?
    dynamic var showTimes: String?
	dynamic var ticketCurrency: String?
	var ticketPrice = RealmOptional<Int>()
    dynamic var theater: MVTheater?
    
    public override static func primaryKey() -> String? {
        return "scheduledTheaterID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        blitzCinType <- map["BlitzCinType"]
        movieFormat <- map["MovieFormat"]
        showDate <- (map["ShowDate"], DateTransform())
        showTimes <- map["ShowTimes"]
        ticketCurrency <- map["TicketCurrency"]
        ticketPrice <- (map["TicketPrice"], RealmOptionalTransform<Int>())
        
        if let showDateString = showDate?.format(with: "yyyy-MM-dd"),
            let theaterID = map.JSON["TheaterID"] as? Int64 {
            
            scheduledTheaterID = "\(showDateString)-\(theaterID)"
        }
        
        theater = Mapper<MVTheater>().map(JSON: map.JSON)
    }
}

extension MVScheduledTheater {
    
    func showTimesArray() -> [String] {
        
        var showTimes: [String] = []
        if let s = self.showTimes {
            showTimes = s.components(separatedBy: CharacterSet(charactersIn: "|"))
        }
        
        return showTimes
    }
}
