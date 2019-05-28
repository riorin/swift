//
//  Services.swift
//  TableViewDemo
//
//  Created by Bayu Yasaputro on 29/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation
import Moya

let kTmdbApiKey = "9548fa0910e2897f79dfdc19e0b2e9a0"

let provider = MoyaProvider<Services>()

enum Services {
    case discoverMovie(Int)
    case movie(Int)
}

extension Services: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    var path: String {
        
        switch self {
        case .discoverMovie:
            return "/discover/movie"
            
        case .movie(let movieId):
            return "/movie/\(movieId)"
        }
    }
    
    var method: Moya.Method {
        
        switch self {
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        
        return Data()
    }
    
    var task: Task {
        
        switch self {
        case .discoverMovie(let page):
            let params: [String: Any] = [
                "primary_release_date.gte": "2018-01-01",
                "api_key": kTmdbApiKey,
                "page" : page
            ]
            
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
            
        case .movie:
            let params = [
                "api_key": kTmdbApiKey
            ]
            
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

