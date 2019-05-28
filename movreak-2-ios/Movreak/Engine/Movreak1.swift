//
//  Movreak1.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/20/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Moya
import UIImageColors
import SDWebImage

typealias Completion = () -> Void

private var userAgent: String {
    let bundleVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    let model = UIDevice.current.model
    let systemVersion = UIDevice.current.systemVersion
    let scale = String(format: "%.2f", UIScreen.main.scale)
    
    return "Movreak/\(bundleVersion) (\(model); iOS \(systemVersion); Scale/\(scale))"
}

private var headers: [String: String] {
    var authorization = ""
    
    var username = kMovreakSvcUsername
    var password = kMovreakSvcPassword
    if let userIdentifier = UserManager.shared.profile?.userIdentifier {
        username = userIdentifier
        password = userIdentifier
    }
    
    if let authorizationData = "\(username):\(password)".data(using: String.Encoding.utf8) {
        authorization = authorizationData.base64EncodedString(options: [])
    }
    
    return [
        "User-Agent": userAgent,
        "Accept": "application/json",
        "DataServiceVersion": "1.0",
        "X-TimeZone-Offset": "\(TimeZone.current.secondsFromGMT() / 3600)",
        "Authorization": "Basic \(authorization)"
    ]
}

private let endpointClosure = { (target: Movreak1) -> Endpoint in
    let defaultEndpoint = CGDataProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: headers)
}

let provider = CGDataProvider(endpointClosure: endpointClosure)
let disposeBag = DisposeBag()
var realm: Realm {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.realm
}

var imageColorsCache: [URL: UIImageColors] = [:]
func loadImageAndImageColors(with url: URL, completion: @escaping (_ image: UIImage?, _ colors: UIImageColors?) -> Void) {
    
    SDWebImageManager.shared().downloadImage(with: url, options: [], progress: { (_, _) in }, completed: { (image, _, _, _, _) in
        if let image = image {
            if let imageColors = imageColorsCache[url] {
                completion(image, imageColors)
            }
            else {
                image.getColors { (imageColors) in
                    imageColorsCache[url] = imageColors
                    completion(image, imageColors)
                }
            }
        }
        else {
            completion(nil, nil)
        }
    })
}

enum Movreak1 {
    
    // MARK: Log In
    case home(MVCity)
    case clientSetting
    case supportedCity(String?)
    
    case comingSoon(String, String)
    case movieList(String)
    case popularMovies(Int, String)
    
    
    // MARK: Trailer
    case trailers(Int, Bool)
    
    // MARK: Movie
    case movieSchedule(Date, String)
    case movieDetail(Int64)
    case movieInfos(Int64)
    case movieTrailers(Int64)
    case movieSearch(String, Int?)
    
    // MARK: - News
    case news(Int)
    
    // MARK: Theater
    case theaterSchedule(Date, String)
    case theaterDetail(Int64)
    
    // MARK: Review
    case userReviews(ReviewFilter, Int)
    case postReview(MVReview)
    case likeReview(MVLike)
    case unlikeReview(Int64)
    case flagReview(MVFlag)
    case deleteReview(Int64)
    
    // MARK: Profile
    case profile(Int64)
    case watchedMovie(String, Int)
    
    case adsDetail(Int64)
}

extension Movreak1: TargetType {

    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "http://api1.movreak.com")!
    }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .clientSetting:
            return "/Api/Config/ClientSetting"
            
        case .supportedCity:
            return "/Api/Cities/Supported"
            
        case .home:
            return "/Api/Home"
            
        case .comingSoon:
            return kMovieComingSoonPathUrl
            
        case .movieList:
            return kMovieListPathUrl
            
        case .popularMovies:
            return kPopularMoviesPathUrl
            
        case .trailers:
            return kTrailersPathUrl
            
        // MARK: Movie
        case .movieSchedule:
            return kMovieScheduleByDateAndCityPathUrl
        case .movieDetail:
            return kMovieDetailPathUrl
        case .movieInfos:
            return kMovieInfoPathUrl
        case .movieTrailers:
            return kMovieTrailersPathUrl
        case .movieSearch:
            return kMovieSearch
            
        // MARK: News
        case .news:
            return kNewsGeneralPathUrl
            
        // MARK: User Review
        case .userReviews:
            return kAllUserReviewPathUrl
        case .postReview:
            return kUserReviewPostPathUrl
        case .likeReview:
            return kLikeUserReviewPostPathUrl
        case .unlikeReview:
            return kUnlikeUserReviewPostPathUrl
        case .flagReview:
            return kFlagUserReviewPostPathUrl
        case .deleteReview(let reviewID):
            return String(format: kAUserReviewPathUrl, "\(reviewID)")
            
        // MARK: Theater
        case .theaterSchedule:
            return kTheaterScheduleByDateAndCityPathUrl
        case .theaterDetail:
            return kTheaterDetailPathUrl
            
        // MARK: Profile
        case .profile:
            return kUserProfilePathUrl
        case .watchedMovie:
            return kWatchedMoviesPathUrl
            
        case .adsDetail:
            return kAdsDetailPathUrl
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .postReview, .likeReview, .flagReview:
            return .post
            
        case .deleteReview:
            return .delete
            
        default:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        var parameters: [String: Any]?
        
        switch self {
        case .clientSetting:
            parameters = [
                "os": "iOS",
                "v": kMovreakAppVersionNumber,
                "exclusive": kMovreakExclusive,
                "premium": kMovreakPremium
            ]
            
        case .supportedCity(let countryCode):
            if let countryCode = countryCode { parameters = ["countryCode": countryCode] }
            
        case .home(let city):
            parameters = ["premium": kMovreakPremium]
            if let cityName = city.cityName { parameters?["city"] = cityName }
            if let countryCode = city.countryCode { parameters?["country"] = countryCode }
            
        case .comingSoon(let city, let countryCode):
            parameters = [ "city": city, "country": countryCode, "format": "grouped" ]
            
        case .movieList(let itemID):
            parameters = [ "listID": itemID, "provider": "TMDB" ]
            
        case .popularMovies(let skip, let timeRange):
            parameters = [ "top": 20, "skip": skip, "timeRange": timeRange ]
            
        case .trailers(let skip, let isFeatured):
            parameters = [ "top": 20, "skip": skip, "featured": isFeatured ? "true" : "false" ]
            
        // MARK: Movie
        case .movieSchedule(let date, let city):
            parameters = [
                "showdate": date.format(with: "yyyy-MM-dd"),
                "format": "WithStatus"
            ]
            parameters?["city"] = city
            
        case .movieDetail(let movieID):
            parameters = [ "$filter": "MovieID eq \(movieID)", "$expand": "MovieCollection" ]
            
        case .movieInfos(let movieID):
            parameters = [ "MovieID": movieID, "excludeRT": 1 ]
            
        case .movieTrailers(let movieID):
            parameters = [ "movieID": movieID ]
            
        case .movieSearch(let keyWord, let year):
            parameters = [ "q": keyWord ]
            if let year = year { parameters?["year"] = year }
            
        // MARK: News
        case .news(let page):
            parameters = [ "page": page ]
            
            
        // MARK: User Review
        case .userReviews(let reviewFilter, let skip):
            parameters = [ "top": 10, "skip": skip ]
            switch reviewFilter {
            case .movie(let movieID):
                parameters?["movieID"] = movieID
                
            case .user(let userProfileID):
                parameters?["userpid"] = userProfileID
                
            case .nowPlayingMovie:
                parameters?["onlyNP"] = 1
            
            case .detail(let ReviewID):
                parameters?["reviewID"] = ReviewID
                
            default:
                break
            }
            
        case .postReview(let review):
            parameters = review.asDictionary()
            
        case .likeReview(let like):
            parameters = like.asDictionary()
            
        case .unlikeReview(let reviewID):
            parameters = ["reviewID": reviewID]
            
        case .flagReview(let flag):
            parameters = flag.asDictionary()
            
        case .deleteReview:
            break
            
        // MARK: Theater
        case .theaterSchedule(let date, let city):
            parameters = [
                "showdate": date.format(with: "yyyy-MM-dd")
            ]
            parameters?["city"] = city
            
        case .theaterDetail(let theaterID):
            parameters = [
                "$filter": "TheaterID eq \(theaterID)L",
                "$format": "json"
            ]
            
            
        // MARK: Profile
        case .profile(let profileID):
            parameters = [
                "userpid": profileID
            ]
            
        case .watchedMovie(let timeRange, let skip):
            parameters = [
                "top": 10,
                "status": MovieWatchingStatus.watched.rawValue,
                "timeRange": timeRange,
                "skip": skip
            ]
            
        case .adsDetail(let adsID):
            parameters = [ "AdsID": adsID ]
        }
        
        return parameters
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .postReview, .likeReview, .flagReview:
            return JSONEncoding.prettyPrinted
            
        default:
            return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        return .request
    }

    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
}
