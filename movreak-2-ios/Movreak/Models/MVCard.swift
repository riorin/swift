//
//	MVCard.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift
import ObjectMapper


enum CardType: String {
    case inCinema = "HomeInCinema"
    case featuredNews = "HomeFeaturedNews"
    case latestReviews = "HomeUserReviews"
    case popularMovies = "HomePopularMovies"
    case latestTrailers = "HomeTrailersLatest"
    case featuredTrailers = "HomeTrailersFeatured"
    case comingSoon = "HomeComingSoon"
    case popularMovieList = "HomePopularMovieList"
    case cinemas = "HomeCinemas"
    case ads = "HomeAds"
    
    var description: String {
        
        switch self {
        case .inCinema:
            return "In Cinema"
            
        case .featuredNews:
            return "Featured News"
            
        case .latestReviews:
            return "Latest Reviews"
            
        case .popularMovies:
            return "Popular Movies"
            
        case .latestTrailers:
            return "Latest Trailers"
            
        case .featuredTrailers:
            return "Featured Trailers"
            
        case .comingSoon:
            return "Coming Soon"
            
        case .popularMovieList:
            return "Popular Lists"
            
        case .cinemas:
            return "Cinemas"
            
        case .ads:
            return "Links"
        }
    }
    
    var icon: UIImage? {
        
        var image: UIImage?
        
        switch self {
        case .inCinema:
            image = UIImage(named: "icn_in_cinema")
            
        case .featuredNews:
            image = UIImage(named: "icn_featured_news")
            
        case .latestReviews:
            image = UIImage(named: "icn_latest_reviews")
            
        case .popularMovies:
            image = UIImage(named: "icn_popular_movies")
            
        case .latestTrailers:
            image = UIImage(named: "icn_latest_trailers")
            
        case .featuredTrailers:
            image = UIImage(named: "icn_featured_trailers")
            
        case .comingSoon:
            image = UIImage(named: "icn_coming_soon")
            
        case .popularMovieList:
            image = UIImage(named: "icn_popular_lists")
            
        case .cinemas:
            image = UIImage(named: "icn_in_cinema")
            
        default:
            break
        }
        
        return image
    }
}

class MVCard: Object, Mappable {
    
    @objc dynamic var sectionID: String = ""
	var displayOrder = RealmOptional<Int>()
    @objc dynamic var itemGroup: String?
    @objc dynamic var itemType: String?
    @objc dynamic var lastRefreshDate: String?
	var refreshIntervalSeconds = RealmOptional<Int>()
    @objc dynamic var seeAllText: String?
    @objc dynamic var title: String?
    
    var inCinema = List<MVMovie>()
    var featuredNews = List<MVNews>()
    var latestReviews = List<MVReview>()
    var popularMovies = List<MVMovie>()
    var featuredTrailers = List<MVTrailer>()
    var comingSoon = List<MVMovie>()
    var latestTrailers = List<MVTrailer>()
    var popularMovieList = List<MVMovieList>()
    var links = List<MVLink>()

    var isHidden = RealmOptional<Bool>()
    
    public override static func primaryKey() -> String? {
        return "sectionID"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        sectionID <- map["SectionID"]
		displayOrder <- (map["DisplayOrder"], RealmOptionalTransform<Int>())
		itemGroup <- map["ItemGroup"]
		itemType <- map["ItemType"]
		lastRefreshDate <- map["LastRefreshDate"]
		refreshIntervalSeconds <- (map["RefreshIntervalSeconds"], RealmOptionalTransform<Int>())
        seeAllText <- map["SeeAllText"]
		title <- map["Title"]
        
        if let cardType = CardType(rawValue: sectionID) {
            
            switch cardType {
            case .inCinema:
                inCinema <- (map["Items"], ListTransform<MVMovie>())
                if isHidden.value == nil { isHidden.value = false }
                
            case .popularMovies:
                popularMovies <- (map["Items"], ListTransform<MVMovie>())
                if isHidden.value == nil { isHidden.value = false }
                
            case .comingSoon:
                comingSoon <- (map["Items"], ListTransform<MVMovie>())
                if isHidden.value == nil { isHidden.value = false }
                
            case .latestReviews:
                latestReviews <- (map["Items"], ListTransform<MVReview>())
                if isHidden.value == nil { isHidden.value = false }
                
            case .featuredTrailers:
                featuredTrailers <- (map["Items"], ListTransform<MVTrailer>())
                if isHidden.value == nil { isHidden.value = false }
                
            case .latestTrailers:
                latestTrailers <- (map["Items"], ListTransform<MVTrailer>())
                if isHidden.value == nil { isHidden.value = false }
                
            case .popularMovieList:
                popularMovieList <- (map["Items"], ListTransform<MVMovieList>())
                if isHidden.value == nil { isHidden.value = true }
                
            case .featuredNews:
                featuredNews <- (map["Items"], ListTransform<MVNews>())
                isHidden.value = true
                
            default:
                links <- (map["Items"], ListTransform<MVLink>())
            }
        }
	}
}

extension MVCard {
    
    class func homeCinamasCard() -> MVCard {
        
        let realm = try! Realm()
        if let object = realm.object(ofType: MVCard.self, forPrimaryKey: CardType.cinemas.rawValue) {
            return object
        }
        else {
        
            let card = MVCard()
            card.sectionID = CardType.cinemas.rawValue
            card.displayOrder.value = 9
            card.itemGroup = "MainSections"
            card.itemType = "Theater"
            card.seeAllText = "SEE ALL"
            card.title = "CINEMAS"
            card.isHidden.value = true
            
            try! realm.write {
                realm.add(card, update: true)
            }
            
            return card
        }
    }
}
