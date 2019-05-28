//
//	MVTheater.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


enum Cineplex: String {
    case cinema21 = "21CINEPLEX"
    case blitz = "BLITZ"
    case cinemaxx = "CINEMAXX"
    
    var description: String {
        switch self {
        case .cinema21:
            return "Cinema 21"
            
        case .blitz:
            return "CGV Cinemas"
            
        case .cinemaxx:
            return "Cinemaxx"
        }
    }
}

class MVTheater: Object, Mappable {
    
    dynamic var theaterID: Int64 = 0
	dynamic var address: String?
	dynamic var blitzCinID: String?
	dynamic var blitzCinType: String?
	var c21CinID = RealmOptional<Int64>()
	dynamic var c21MTixCode: String?
    dynamic var cineplexID: String?
	dynamic var cityName: String?
	dynamic var countryCode: String?
	dynamic var countryName: String?
	dynamic var coverPosterUrl: String?
	dynamic var detailUrl: String?
	dynamic var facebookLocationID: String?
	dynamic var foursquareVenueID: String?
	dynamic var lastModifiedDate: String?
	var mapLat = RealmOptional<Double>()
	var mapLong = RealmOptional<Double>()
	dynamic var name: String?
	dynamic var phone: String?
	dynamic var remarks: String?
	dynamic var reservedProperty1: String?
	dynamic var reservedProperty2: String?
	dynamic var reservedProperty3: String?
    var ticketing = RealmOptional<Bool>()
	dynamic var zipCode: String?
    
    
    public override static func primaryKey() -> String? {
        return "theaterID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        theaterID <- (map["TheaterID"], Int64Transform())
		address <- map["Address"]
		blitzCinID <- map["BlitzCinID"]
		blitzCinType <- map["BlitzCinType"]
		c21CinID <- (map["C21CinID"], RealmOptionalTransform<Int64>())
		c21MTixCode <- map["C21MTixCode"]
        cineplexID <- map["CineplexID"]
		cityName <- map["CityName"]
		countryCode <- map["CountryCode"]
		countryName <- map["CountryName"]
		coverPosterUrl <- map["CoverPosterUrl"]
		detailUrl <- map["DetailUrl"]
		facebookLocationID <- map["FacebookLocationID"]
		foursquareVenueID <- map["FoursquareVenueID"]
		lastModifiedDate <- map["LastModifiedDate"]
		mapLat <- (map["MapLat"], RealmOptionalTransform<Double>())
		mapLong <- (map["MapLong"], RealmOptionalTransform<Double>())
		name <- map["Name"]
		phone <- map["Phone"]
		remarks <- map["Remarks"]
		reservedProperty1 <- map["ReservedProperty1"]
		reservedProperty2 <- map["ReservedProperty2"]
		reservedProperty3 <- map["ReservedProperty3"]
        ticketing <- (map["Ticketing"], RealmOptionalTransform<Bool>())
		zipCode <- map["ZipCode"]
        
        let r = try! Realm()
        if let object = r.object(ofType: MVTheater.self, forPrimaryKey: theaterID) {
            for property in objectSchema.properties {
                if property == objectSchema.primaryKeyProperty { continue }
                if self.value(forKey: property.name) == nil {
                    self.setValue(object.value(forKey: property.name), forKey: property.name)
                }
            }
        }
	}
}


extension MVTheater {
    
    func cineplex() -> Cineplex? {
        var cineplex: Cineplex?
        if let cineplexID = cineplexID {
            cineplex = Cineplex(rawValue: cineplexID)
        }
        return cineplex
    }
    
    class func defaultCoverImage() -> UIImage {
        return kDefaultTheaterImage
    }
}
