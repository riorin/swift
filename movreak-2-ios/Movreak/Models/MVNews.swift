//
//	MVNews.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper
import Kanna
import SwiftyJSON

class MVNews: Object, Mappable {
    
    dynamic var id: Int64 = 0
	dynamic var adsImageUrl: String?
	dynamic var adsVideoDirectUrl: String?
	dynamic var adsVideoPageUrl: String?
	dynamic var attachments: String?
	dynamic var author: MVNewsAuthor?
	var categories = List<MVNewsCategory>()
    var commentCount = RealmOptional<Int>()
	dynamic var commentStatus: String?
	dynamic var comments:String?
	dynamic var content: String?
	dynamic var date: Date?
	dynamic var excerpt: String?
	dynamic var modified: Date?
	dynamic var slug: String?
	dynamic var status: String?
	var tags = List<MVNewsTag>()
	dynamic var title: String?
	dynamic var titlePlain: String?
	dynamic var type: String?
	dynamic var url: String?
    
    dynamic var enclosure: String?
    dynamic var syndicationSource: String?
    dynamic var syndicationSourceUri: String?
    dynamic var syndicationSourceId: String?
    dynamic var syndicationFeed: String?
    dynamic var syndicationFeedId: String?
    dynamic var syndicationPermalink: String?
    dynamic var syndicationItemHash: String?
    
    var images = List<MVNewsImage>()
    
    public override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
		adsImageUrl <- map["AdsImageUrl"]
		adsVideoDirectUrl <- map["AdsVideoDirectUrl"]
		adsVideoPageUrl <- map["AdsVideoPageUrl"]
		attachments <- (map["attachments"], JSONTransfrom())
		author <- map["author"]
		categories <- (map["categories"], ListTransform<MVNewsCategory>())
		commentCount <- (map["comment_count"], RealmOptionalTransform<Int>())
		commentStatus <- map["comment_status"]
		comments <- (map["comments"], JSONTransfrom())
		content <- map["content"]
		date <- (map["date"], DateTransform())
		excerpt <- map["excerpt"]
		modified <- (map["modified"], DateTransform())
		slug <- map["slug"]
		status <- map["status"]
		tags <- (map["tags"], ListTransform<MVNewsTag>())
		title <- map["title"]
		titlePlain <- map["title_plain"]
		type <- map["type"]
		url <- map["url"]
        
        enclosure <- map["custom_fields.enclosure.0"]
        syndicationSource <- map["custom_fields.syndication_source.0"]
        syndicationSourceUri <- map["custom_fields.syndication_source_uri.0"]
        syndicationSourceId <- map["custom_fields.syndication_source_id.0"]
        syndicationFeed <- map["custom_fields.syndication_feed.0"]
        syndicationFeedId <- map["custom_fields.syndication_feed_id.0"]
        syndicationPermalink <- map["custom_fields.syndication_permalink.0"]
        syndicationItemHash <- map["custom_fields.syndication_item_hash.0"]
        
        if let content = content {
            if let doc = HTML(html: content, encoding: .utf8) {
                
                // Search for nodes by CSS
                for link in doc.css("div") {
                    if let className = link.className, className == "image" {
                        if let innerHTML = link.innerHTML {
                            if let doc = HTML(html: innerHTML, encoding: .utf8) {
                                for link in doc.css("img") {
                                    
                                    var json: [String: Any] = [:]
                                    if let src = link["src"] {
                                        json["url"] = src
                                        if let alt = link["alt"] {
                                            json["title"] = alt
                                        }
                                        
                                        if let image = MVNewsImage(JSON: json) {
                                            images.append(image)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
		
        let r = try! Realm()
        if let object = r.object(ofType: MVNews.self, forPrimaryKey: id) {
            for property in objectSchema.properties {
                if property == objectSchema.primaryKeyProperty { continue }
                if self.value(forKey: property.name) == nil {
                    self.setValue(object.value(forKey: property.name), forKey: property.name)
                }
            }
        }
	}
}

extension MVNews {
    
    func updateImages(with json: JSON) {
        
        if let item = json["items"].array?.first {
            if let thumbnailSmallUrl = item["snippet"]["thumbnails"]["medium"]["url"].string {
                
                var json: [String: Any] = ["url": thumbnailSmallUrl]
                if let title = item["snippet"]["title"].string {
                    json["title"] = title
                }
                if let image = MVNewsImage(JSON: json) {
                    images.append(image)
                }
            }
        }
    }
}
