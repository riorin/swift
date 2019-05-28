//
//  TMDb.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/7/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RxSwift
import Moya

let tmdbProvider = CGDataProvider()

enum TMDb {
    case configuration
    case movie(String)
    case movieImages(String)
    case movieTrailers(String)
    case movieLists(String)
    case list(String)
}

extension TMDb: TargetType {
    var headers: [String : String]? {

    }
    
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "https://api.themoviedb.org")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .configuration:
            return "/3/configuration"
            
        case .movie(let movieID):
            return "/3/movie/\(movieID)"
            
        case .movieImages(let movieID):
            return "/3/movie/\(movieID)/images"
            
        case .movieTrailers(let movieID):
            return "/3/movie/\(movieID)/trailers"
            
        case .movieLists(let movieID):
            return "/3/movie/\(movieID)/lists"
            
        case .list(let listID):
            return "/3/list/\(listID)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .get
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        return ["api_key": kTmdbApiKey]
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
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
