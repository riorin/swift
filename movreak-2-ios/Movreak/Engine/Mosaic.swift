//
//  Mosaic.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/21/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Moya

private var headers: [String: String] {
    
    var headers: [String: String] = ["Content-Type": "application/json"]
    if let userProfileID = UserManager.shared.profile?.userProfileID {
        headers["Movreak-Uid"] = "\(userProfileID)"
    }
    
    return headers
}

private let endpointClosure = { (target: Mosaic) -> Endpoint in
    let defaultEndpoint = CGDataProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: headers)
}

let mosaicProvider = CGDataProvider(endpointClosure: endpointClosure)

enum Mosaic {
    case activity([String: Any])
    case homeActivity
    case userActivity(String)
    case userFollowsUser(String, String)
    case userDetail(String)
}

extension Mosaic: TargetType {
    
    /// The target's base `URL`.
    public var baseURL: URL {
        return URL(string: "http://node.jepret.me")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .activity:
            return "/mosaic/v1/activity"
            
        case .homeActivity:
            return "/mosaic/v1/home/activity"
            
        case .userActivity(let userID):
            return "/mosaic/v1/user/\(userID)/activity"
            
        case .userFollowsUser(let userID, let followedUserID):
            return "/mosaic/v1/user/\(userID)/follows/\(followedUserID)"
            
        case .userDetail(let userID):
            return "/mosaic/v1/user/\(userID)"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .activity:
            return .post
            
        case .homeActivity, .userActivity, .userFollowsUser, .userDetail:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        switch self {
        case .activity(let parameters):
            return parameters
            
        case .homeActivity:
            break
            
        case .userActivity:
            break
            
        case .userFollowsUser:
            break
            
        case .userDetail:
            break
        }
        
        return nil
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .activity:
            return JSONEncoding.prettyPrinted
            
        case .homeActivity, .userActivity, .userFollowsUser, .userDetail:
            return URLEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    public var task: Task {
        switch self {
        case .activity, .homeActivity, .userActivity, .userFollowsUser, .userDetail:
            return .request
        }
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    public var validate: Bool {
        return false
    }
}
