//
//  MovreakCMS.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/7/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RxSwift
import Moya

let cmsProvider = CGDataProvider()

enum MovreakCMS {
    case featuredNews(Int)
}

extension MovreakCMS: TargetType {
    var headers: [String : String]? {
        <#code#>
    }
    
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "http://cms.movreak.com")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .featuredNews:
            return "/Api/News/Featured"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .get
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .featuredNews(let skip):
            return [ "skip": skip, "top": 10, "timeRange": "today" ]
        }
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
