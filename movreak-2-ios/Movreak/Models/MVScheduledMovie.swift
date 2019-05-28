//
//	MVScheduledMovie.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper
import SDWebImage


class MVScheduledMovie: Object, Mappable {
    
    dynamic var scheduledMovieID: String = ""
    dynamic var blitzCinType: String?
    dynamic var movieFormat: String?
    dynamic var showDate: Date?
    dynamic var showTimes: String?
    dynamic var ticketCurrency: String?
    var ticketPrice = RealmOptional<Int>()
    dynamic var movie: MVMovie?

    public override static func primaryKey() -> String? {
        return "scheduledMovieID"
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
            let movieID = map.JSON["MovieID"] as? Int64 {
            
            scheduledMovieID = "\(showDateString)-\(movieID)"
        }
        
        movie = Mapper<MVMovie>().map(JSON: map.JSON)
	}
}

extension MVScheduledMovie {
    
    func showTimesArray() -> [String] {
        
        var showTimes: [String] = []
        if let s = self.showTimes {
            showTimes = s.components(separatedBy: CharacterSet(charactersIn: "|"))
        }
        
        return showTimes
    }
}
