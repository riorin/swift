//
//	MVTrailer.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


class MVTrailer: Object, Mappable {
    
    dynamic var movieTrailerID: Int64 = 0
	dynamic var createdDate: Date?
	dynamic var descripción: String?
    dynamic var duration: String?
    var durationSecond = RealmOptional<Int>()
	var featured = RealmOptional<Bool>()
	dynamic var lastModifiedDate: Date?
	dynamic var movie: MVMovie?
    dynamic var playerHtml: String?
	dynamic var shortDescription: String?
	dynamic var source: String?
	dynamic var sourceID: String?
	dynamic var thumbnailBigUrl: String?
	dynamic var thumbnailSmallUrl: String?
	dynamic var title: String?
	dynamic var videoDirectUrl: String?
    dynamic var videoPageUrl: String?
    dynamic var youtubeVideoID: String?


    public override static func primaryKey() -> String? {
        return "movieTrailerID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        movieTrailerID <- map["MovieTrailerID"]
		createdDate <- (map["CreatedDate"], DateTransform())
		descripción <- map["Description"]
        duration <- map["Duration"]
        durationSecond <- (map["DurationSecond"], RealmOptionalTransform<Int>())
		featured <- (map["Featured"], RealmOptionalTransform<Bool>())
		lastModifiedDate <- (map["LastModifiedDate"], DateTransform())
		movie <- map["Movie"]
        playerHtml <- map["PlayerHtml"]
		shortDescription <- map["ShortDescription"]
		source <- map["Source"]
		sourceID <- map["SourceID"]
		thumbnailBigUrl <- map["ThumbnailBigUrl"]
		thumbnailSmallUrl <- map["ThumbnailSmallUrl"]
		title <- map["Title"]
		videoDirectUrl <- map["VideoDirectUrl"]
        videoPageUrl <- map["VideoPageUrl"]
		youtubeVideoID <- map["YoutubeVideoID"]
        
        let r = try! Realm()
        if let object = r.object(ofType: MVTrailer.self, forPrimaryKey: movieTrailerID) {
            for property in objectSchema.properties {
                if property == objectSchema.primaryKeyProperty { continue }
                if self.value(forKey: property.name) == nil {
                    self.setValue(object.value(forKey: property.name), forKey: property.name)
                }
            }
        }
	}
}
