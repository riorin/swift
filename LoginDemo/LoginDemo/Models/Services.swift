//
//  Services.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 04/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation
import Moya

let kTmdbApiKey = "9548fa0910e2897f79dfdc19e0b2e9a0"

let provider = MoyaProvider<Services>()

enum Services {
    ///parameters: page
    case discoverMovie(Int)
    
    case createRequestToken
    
    ///parameters: request_token
    case createSession(String)
}

extension Services: TargetType  {
    
    var baseURL: URL {
        #if (DEV)
            return URL(string: "https://dev-api.themoviedb.org/3")!
        #else
            return URL(string: "https://api.themoviedb.org/3")!
        #endif
    }
    
    var path: String {
        
        switch self {
        case .discoverMovie:
            return "/discover/movie"
            
        case .createRequestToken:
            return "/authentication/token/new"
            
        case .createSession:
            return "/authentication/session/new"
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
            let parameters: [String: Any] = [
                "primary_release_date.gte": "2018-01-01",
                "api_key": kTmdbApiKey,
                "page": page
            ]
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.default
            )
            
        case .createRequestToken:
            return .requestParameters(
                parameters: ["api_key": kTmdbApiKey],
                encoding: URLEncoding.default
            )
            
        case .createSession(let requestToken):
            return .requestParameters(
                parameters: [
                    "api_key": kTmdbApiKey,
                    "request_token": requestToken
                ],
                encoding: URLEncoding.default
            )
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
