//
//  OAuthPath.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RxSwift
import Moya

enum PathApiMode: Int {
    
    case hybrid = 0
    case basic = 1
    case oauth = 2
}

let oAuthPathProvider = CGDataProvider()

enum OAuthPath {
    case accessToken(String)
}

extension OAuthPath: TargetType {
    var headers: [String : String]? {
        <#code#>
    }
    
    
    var baseURL: URL {
        return URL(string: "https://partner.path.com")!
    }
    
    var path: String {
        switch self {
        case .accessToken:
            return "/oauth2/access_token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .accessToken:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .accessToken(let code):
            return [
                "grant_type": "authorization_code",
                "client_id": kPathClientId,
                "client_secret": kPathClientSecret,
                "code": code
            ]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .accessToken:
            return URLEncoding.default
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .accessToken:
            return .request
        }
    }
    
    var validate: Bool {
        return false
    }
}
