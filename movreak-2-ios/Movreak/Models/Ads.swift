//
//  Ads.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/1/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class Ads: Object {
    
    dynamic var adsCampaign: String?
    dynamic var adsCustomConfig: String?
    dynamic var adsID: Int64 = 0
    let adsOrder = RealmOptional<Int>()
    dynamic var adsPlacementPage: String?
    dynamic var adsPlacementPosition: String?
    dynamic var adsType: String?
    dynamic var bigImageUrl: String?
    dynamic var createdDate: Date?
    dynamic var deactivatedDate: Date?
    dynamic var detailUrl: String?
    let displayOnEachRowOf = RealmOptional<Int>()
    dynamic var displayOnMovieGenre: String?
    let displayOnMovieID = RealmOptional<Int64>()
    let displayOnRow = RealmOptional<Int>()
    dynamic var endDate: Date?
    dynamic var featured: Bool = false
    dynamic var homepage: String?
    dynamic var imageSize: String?
    dynamic var imageUrl: String?
    dynamic var isActive: Bool = false
    dynamic var languages: String?
    dynamic var lastModifiedDate: Date?
    dynamic var relatedMovieImdbMovID: String?
    dynamic var remarks: String?
    dynamic var reservedProperty1: String?
    dynamic var reservedProperty2: String?
    dynamic var reservedProperty3: String?
    dynamic var reservedProperty4: String?
    dynamic var reservedProperty5: String?
    let skipableAfterSeconds = RealmOptional<Int>()
    dynamic var startDate: Date?
    dynamic var synopsis: String?
    dynamic var synopsisEnglish: String?
    dynamic var tagline: String?
    dynamic var targetOS: String?
    dynamic var thumbnailUrl: String?
    dynamic var title: String?
    dynamic var trackingCode: String?
    dynamic var videoAutoPlay: Bool = false
    dynamic var videoDirectUrl: String?
    let videoDuration = RealmOptional<Int>()
    dynamic var videoPageUrl: String?
    dynamic var adsClient : AdsClient?
    
    override class func primaryKey() -> String? {
        return "adsID"
    }
    
    class func from(json: JSON) -> Ads {
    
        let ads = Ads()
        
        ads.adsCampaign = json["AdsCampaign"].string
        ads.adsCustomConfig = json["AdsCustomConfig"].string
        ads.adsID = json["AdsID"].int64Value
        ads.adsOrder.value = json["AdsOrder"].int
        ads.adsPlacementPage = json["AdsPlacementPage"].string
        ads.adsPlacementPosition = json["AdsPlacementPosition"].string
        ads.adsType = json["AdsType"].string
        ads.bigImageUrl = json["BigImageUrl"].string
        ads.createdDate = json["CreatedDate"].stringValue.date()
        ads.deactivatedDate = json["DeactivatedDate"].stringValue.date()
        ads.detailUrl = json["DetailUrl"].string
        ads.displayOnEachRowOf.value = json["DisplayOnEachRowOf"].int
        ads.displayOnMovieGenre = json["DisplayOnMovieGenre"].string
        ads.displayOnMovieID.value = json["DisplayOnMovieID"].int64
        ads.displayOnRow.value = json["DisplayOnRow"].int
        ads.endDate = json["EndDate"].stringValue.date()
        ads.featured = json["Featured"].boolValue
        ads.homepage = json["Homepage"].string
        ads.imageSize = json["ImageSize"].string
        ads.imageUrl = json["ImageUrl"].string
        ads.isActive = json["IsActive"].boolValue
        ads.languages = json["Languages"].string
        ads.lastModifiedDate = json["LastModifiedDate"].stringValue.date()
        ads.relatedMovieImdbMovID = json["RelatedMovieImdbMovID"].string
        ads.remarks = json["Remarks"].string
        ads.reservedProperty1 = json["ReservedProperty1"].string
        ads.reservedProperty2 = json["ReservedProperty2"].string
        ads.reservedProperty3 = json["ReservedProperty3"].string
        ads.reservedProperty4 = json["ReservedProperty4"].string
        ads.reservedProperty5 = json["ReservedProperty5"].string
        ads.skipableAfterSeconds.value = json["SkipableAfterSeconds"].int
        ads.startDate = json["StartDate"].stringValue.date()
        ads.synopsis = json["Synopsis"].string
        ads.synopsisEnglish = json["SynopsisEnglish"].string
        ads.tagline = json["Tagline"].string
        ads.targetOS = json["TargetOS"].string
        ads.thumbnailUrl = json["ThumbnailUrl"].string
        ads.title = json["Title"].string
        ads.trackingCode = json["TrackingCode"].string
        ads.videoAutoPlay = json["VideoAutoPlay"].boolValue
        ads.videoDirectUrl = json["VideoDirectUrl"].string
        ads.videoDuration.value = json["VideoDuration"].int
        ads.videoPageUrl = json["VideoPageUrl"].string
        
        if json["AdsClient"]["AdsClientID"].int64 != nil {
            ads.adsClient = AdsClient.from(json: json["AdsClient"])
        }
        
        return ads
    }
    
}
