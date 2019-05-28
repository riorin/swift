//
//	MVWatching.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


class MVWatching: Object, Mappable {
    
    dynamic var watchingID: Int64 = 0
	dynamic var cityName: String?
    var hoster = RealmOptional<Bool>()
//	dynamic var invitedFriends: [AnyObject]?
	dynamic var lastModifiedDate: Date?
	dynamic var movie: MVMovie?
    var reviewID = RealmOptional<Int64>()
    var reviewed = RealmOptional<Bool>()
	dynamic var status: String?
	dynamic var submittedDate: Date?
	dynamic var user: MVUser?
	dynamic var watchingDateTime: Date?


    public override static func primaryKey() -> String? {
        return "watchingID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        watchingID <- map["WatchingID"]
		cityName <- map["CityName"]
		hoster <- (map["Hoster"], RealmOptionalTransform<Bool>())
//		invitedFriends <- map["InvitedFriends"]
		lastModifiedDate <- (map["LastModifiedDate"], DateTransform())
		movie <- map["Movie"]
		reviewID <- (map["ReviewID"], RealmOptionalTransform<Int64>())
		reviewed <- (map["Reviewed"], RealmOptionalTransform<Bool>())
		status <- map["Status"]
		submittedDate <- (map["SubmittedDate"], DateTransform())
		user <- map["User"]
		watchingDateTime <- (map["WatchingDateTime"], DateTransform())
		
	}
}
