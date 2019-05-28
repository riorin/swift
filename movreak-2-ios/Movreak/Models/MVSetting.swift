//
//	MVSetting.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


class MVSetting: Object, Mappable {

    dynamic var id: Int = 0
	dynamic var adsDisabledInPages: String?
	dynamic var adsEnabled: Bool = false
	dynamic var adsSplashScreenEnabled: Bool = false
	dynamic var blitzCheckSeatEnabled: Bool = false
	dynamic var blitzTicketPurchaseEnabled: Bool = false
	dynamic var blitzTicketPurchaseNativeMode: Bool = false
	dynamic var checkSeatsURL: String?
	dynamic var cineplex21CitiesJson: String?
	dynamic var creatingTicketPassEnabled: Bool = false
    dynamic var dailyScheduleCollectingTimes: String?
	dynamic var disableDirectAccessToTmdb: Bool = false
	dynamic var disableImdbInterception: Bool = false
	dynamic var disableRottenTomatoesInterception: Bool = false
	dynamic var excludedAutoFollowTwitterUsers: String?
	dynamic var featureIsNotAvailableInFreeVersionText: String?
	dynamic var genericTicketPurchaseEnabled: Bool = false
    var imdbNewsCategories = List<MVImdbNewsCategory>()
    dynamic var lastRefreshDate: Date?
	dynamic var loadingMessages: String?
	dynamic var movieRelatedNewsFromImdb: Bool = false
	dynamic var movieScheduleRefreshTimeInterval: Int = 21600
	dynamic var newsReaderArticleContentXPath: String?
	dynamic var newsReaderRenderHtmlDirectlyOnWebView: Bool = false
	dynamic var newsReaderUrlFormat: String?
	dynamic var newsRefreshTimeInterval: Int = 21600
	dynamic var newsRootUrl: String?
	dynamic var newsURLPatternsConsideredAsMovieLink: String?
	dynamic var newsURLPatternsDontUseReader: String?
	dynamic var newsUseContentFromMovreakWeb: Bool = false
	dynamic var noScheduleText: String?
	dynamic var playYouTubeVideoOnWebView: Bool = false
	dynamic var rtAfterLoadingReviewsScript: String?
	dynamic var twitterUsersToFollow: String?

    
    public override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
		adsDisabledInPages <- (map["AdsDisabledInPages"], JSONTransfrom())
		adsEnabled <- map["AdsEnabled"]
		adsSplashScreenEnabled <- map["AdsSplashScreenEnabled"]
		blitzCheckSeatEnabled <- map["BlitzCheckSeatEnabled"]
		blitzTicketPurchaseEnabled <- map["BlitzTicketPurchaseEnabled"]
		blitzTicketPurchaseNativeMode <- map["BlitzTicketPurchaseNativeMode"]
		checkSeatsURL <- map["CheckSeatsURL"]
		cineplex21CitiesJson <- map["Cineplex21CitiesJson"]
		creatingTicketPassEnabled <- map["CreatingTicketPassEnabled"]
		dailyScheduleCollectingTimes <- (map["DailyScheduleCollectingTimes"], JSONTransfrom())
		disableDirectAccessToTmdb <- map["DisableDirectAccessToTmdb"]
		disableImdbInterception <- map["DisableImdbInterception"]
		disableRottenTomatoesInterception <- map["DisableRottenTomatoesInterception"]
		excludedAutoFollowTwitterUsers <- (map["ExcludedAutoFollowTwitterUsers"], JSONTransfrom())
		featureIsNotAvailableInFreeVersionText <- map["FeatureIsNotAvailableInFreeVersionText"]
		genericTicketPurchaseEnabled <- map["GenericTicketPurchaseEnabled"]
		imdbNewsCategories <- (map["ImdbNewsCategories"], ListTransform<MVImdbNewsCategory>())
		loadingMessages <- (map["LoadingMessages"], JSONTransfrom())
		movieRelatedNewsFromImdb <- map["MovieRelatedNewsFromImdb"]
		movieScheduleRefreshTimeInterval <- map["MovieScheduleRefreshTimeInterval"]
		newsReaderArticleContentXPath <- map["NewsReaderArticleContentXPath"]
		newsReaderRenderHtmlDirectlyOnWebView <- map["NewsReaderRenderHtmlDirectlyOnWebView"]
		newsReaderUrlFormat <- map["NewsReaderUrlFormat"]
		newsRefreshTimeInterval <- map["NewsRefreshTimeInterval"]
		newsRootUrl <- map["NewsRootUrl"]
		newsURLPatternsConsideredAsMovieLink <- (map["NewsURLPatternsConsideredAsMovieLink"], JSONTransfrom())
		newsURLPatternsDontUseReader <- (map["NewsURLPatternsDontUseReader"], JSONTransfrom())
		newsUseContentFromMovreakWeb <- map["NewsUseContentFromMovreakWeb"]
		noScheduleText <- map["NoScheduleText"]
		playYouTubeVideoOnWebView <- map["PlayYouTubeVideoOnWebView"]
		rtAfterLoadingReviewsScript <- map["RtAfterLoadingReviewsScript"]
		twitterUsersToFollow <- (map["TwitterUsersToFollow"],  JSONTransfrom())
	}
}


extension MVSetting {
    
    class func current() -> MVSetting? {
        
        let realm = try! Realm()
        return realm.objects(MVSetting.self).first
    }
    
    func cineplex21CitiesArray() -> [MVCineplex21City] {
        
        var cities: [MVCineplex21City] = []
        
        if let jsonArray = JSONTransfrom().transformToJSON(cineplex21CitiesJson) as? [[String: Any]] {
            for json in jsonArray {
                if let city = MVCineplex21City(JSON: json) {
                    cities.append(city)
                }
            }
        }
        return cities
    }

    func randomLoadingMessage() -> String {
        
        if let messages = JSONTransfrom().transformToJSON(loadingMessages) as? [String] {
            return messages[Int(arc4random_uniform(UInt32(messages.count)))]
        }
        return "Loading..."
    }
}
