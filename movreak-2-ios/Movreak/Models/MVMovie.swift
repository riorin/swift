//
//  MVMovie.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/28/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper
import SDWebImage


enum MovieWatchingStatus: String {
    case planned = "PLANNED"
    case invited = "PLANNED_INVITED"
    case nowWatching = "NOWWATCHING"
    case watched = "WATCHED"
}

enum MovieWatchingTimeRange: String {
    case allTime = "alltime"
    case month = "month"
    case week = "week"
    case today = "today"
}

class MVMovie: Object, Mappable {
    
    dynamic var movieID: Int64 = 0
    var ads = RealmOptional<Bool>()
    var adsID = RealmOptional<Int64>()
    dynamic var bigPosterUrl : String?
    var duration = RealmOptional<Int>()
    var featured = RealmOptional<Bool>()
    dynamic var genre : String?
    var isNew = RealmOptional<Bool>()
    dynamic var lastModifiedDate : Date?
    dynamic var posterUrl : String?
    dynamic var title : String?
    var year = RealmOptional<Int>()
    
    dynamic var audienceCertifications : String?
    dynamic var blitzMovID : String?
    dynamic var budget : String?
    dynamic var c21MTixCode : String?
    dynamic var casts : String?
    dynamic var detailUrl : String?
    dynamic var homepage : String?
    dynamic var imdbMovID : String?
    var is3D = RealmOptional<Bool>()
    var isAdultMovie = RealmOptional<Bool>()
    var isDigital = RealmOptional<Bool>()
    dynamic var languages : String?
    dynamic var lastRefreshFromImdb : Date?
    dynamic var lastRefreshFromRT : Date?
    dynamic var lastRefreshFromTmdb : Date?
    dynamic var mpaaRating : String?
    dynamic var originalTitle : String?
    dynamic var productionCompanies : String?
    dynamic var productionCountries : String?
    dynamic var rTAudienceRating : String?
    var rTAudienceScore = RealmOptional<Int>()
    dynamic var rTCriticsConsensus : String?
    dynamic var rTCriticsRating : String?
    var rTCriticsScore = RealmOptional<Int>()
    dynamic var releaseDate : Date?
    dynamic var releaseStatus : String?
    dynamic var remarks : String?
    dynamic var reservedProperty1 : String?
    dynamic var reservedProperty2 : String?
    dynamic var reservedProperty3 : String?
    dynamic var revenue : String?
    dynamic var rottenTomatoesID : String?
    dynamic var synopsis : String?
    dynamic var synopsisEnglish : String?
    dynamic var tagline : String?
    dynamic var titleAlsoKnownAs : String?
    dynamic var titleTags : String?
    var tmbdVoteAverage = RealmOptional<Double>()
    var tmbdVoteCount = RealmOptional<Int>()
    dynamic var tmdbID : String?
    var tmdbPopularity = RealmOptional<Double>()
    dynamic var trailerPageUrl : String?
    dynamic var trailerVideoUrl : String?
    
    public override static func primaryKey() -> String? {
        return "movieID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        movieID <- (map["MovieID"], Int64Transform())
        ads <- (map["Ads"], RealmOptionalTransform<Bool>())
        bigPosterUrl <- map["BigPosterUrl"]
        duration <- (map["Duration"], RealmOptionalTransform<Int>())
        featured <- (map["Featured"], RealmOptionalTransform<Bool>())
        genre <- map["Genre"]
        isNew <- (map["IsNew"], RealmOptionalTransform<Bool>())
        lastModifiedDate <- (map["LastModifiedDate"], DateTransform())
        posterUrl <- map["PosterUrl"]
        title <- map["Title"]
        year <- (map["Year"], RealmOptionalTransform<Int>())
        
        audienceCertifications <- map["AudienceCertifications"]
        blitzMovID <- map["BlitzMovID"]
        budget <- map["Budget"]
        c21MTixCode <- map["C21MTixCode"]
        casts <- map["Casts"]
        detailUrl <- map["DetailUrl"]
        homepage <- map["Homepage"]
        imdbMovID <- map["ImdbMovID"]
        is3D <- (map["Is3D"], RealmOptionalTransform<Bool>())
        isAdultMovie <- (map["IsAdultMovie"], RealmOptionalTransform<Bool>())
        isDigital <- (map["IsDigital"], RealmOptionalTransform<Bool>())
        languages <- map["Languages"]
        lastRefreshFromImdb <- (map["LastRefreshFromImdb"], DateTransform())
        lastRefreshFromRT <- (map["LastRefreshFromRT"], DateTransform())
        lastRefreshFromTmdb <- (map["LastRefreshFromTmdb"], DateTransform())
        mpaaRating <- map["MpaaRating"]
        originalTitle <- map["OriginalTitle"]
        productionCompanies <- map["ProductionCompanies"]
        productionCountries <- map["ProductionCountries"]
        rTAudienceRating <- map["RTAudienceRating"]
        rTAudienceScore <- map["RTAudienceScore"]
        rTCriticsConsensus <- map["RTCriticsConsensus"]
        rTCriticsRating <- map["RTCriticsRating"]
        rTCriticsScore <- (map["RTCriticsScore"], RealmOptionalTransform<Int>())
        releaseDate <- (map["ReleaseDate"], DateTransform())
        releaseStatus <- map["ReleaseStatus"]
        remarks <- map["Remarks"]
        reservedProperty1 <- map["ReservedProperty1"]
        reservedProperty2 <- map["ReservedProperty2"]
        reservedProperty3 <- map["ReservedProperty3"]
        revenue <- map["Revenue"]
        rottenTomatoesID <- (map["RottenTomatoesID"], StringTransform())
        synopsis <- map["Synopsis"]
        synopsisEnglish <- map["SynopsisEnglish"]
        tagline <- map["Tagline"]
        titleAlsoKnownAs <- map["TitleAlsoKnownAs"]
        titleTags <- map["TitleTags"]
        tmbdVoteAverage <- (map["TmbdVoteAverage"], RealmOptionalTransform<Double>())
        tmbdVoteCount <- (map["TmbdVoteCount"], RealmOptionalTransform<Int>())
        tmdbID <- map["TmdbID"]
        tmdbPopularity <- (map["TmdbPopularity"], RealmOptionalTransform<Double>())
        trailerPageUrl <- map["TrailerPageUrl"]
        trailerVideoUrl <- map["TrailerVideoUrl"]
        
        let r = try! Realm()
        if let object = r.object(ofType: MVMovie.self, forPrimaryKey: movieID) {
            for property in objectSchema.properties {
                if property == objectSchema.primaryKeyProperty { continue }
                if self.value(forKey: property.name) == nil {
                    self.setValue(object.value(forKey: property.name), forKey: property.name)
                }
            }
        }
    }
}

extension MVMovie {
    
    static func defaultBigPosterImage() -> UIImage {
        return kDefaultBigMovieImage
    }
    
    static func defaultPosterImage() ->  UIImage {
        return kDefaultMovieImage
    }
        
    func posterImage() ->  UIImage? {
        
        var image: UIImage?
        if let posterUrl = posterUrl {
            
            if let url = URL(string: posterUrl) {
                
                let key = SDWebImageManager.shared().cacheKey(for: url)
                image = SDWebImageManager.shared().imageCache.imageFromDiskCache(forKey: key)
            }
        }
        
        return image
    }
    
    func bigPosterImage() ->  UIImage? {
        
        var image: UIImage?
        if let bigPosterUrl = bigPosterUrl {
            
            if let url = URL(string: bigPosterUrl) {
                
                let key = SDWebImageManager.shared().cacheKey(for: url)
                image = SDWebImageManager.shared().imageCache.imageFromDiskCache(forKey: key)
            }
        }
        
        return image
    }
    
    func meta() -> [String: Any] {
        return [
            "__metadata": [
                "uri": "/Movies(\(movieID)L)"
            ]
        ]
    }
}
