//
//  Movreak2.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/18/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Moya

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

private let endpointClosure = { (target: Movreak2) -> Endpoint in
    let defaultEndpoint = CGDataProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: headers)
}

let provider2 = CGDataProvider(endpointClosure: endpointClosure)

enum Movreak2 {
    
    case search(String)
    
    // MARK: Movie
    case movieSearch(String)
    
    // MARK: Theater
    case theaterSearch(String)
}

extension Movreak2: TargetType {
    var headers: [String : String]? {
        <#code#>
    }
    
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "http://movreak.azurewebsites.net")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .search:
            return "/api/Search/SearchAll"
            
        case .movieSearch:
            return "/api/Search/SearchMovies"
            
        case .theaterSearch:
            return "/api/Search/SearchTheater"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .get
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        
        switch self {
        case .search(let q):
            return ["search": q]
            
        case .movieSearch(let q):
            return ["search": q]
            
        case .theaterSearch(let q):
            return ["search": q]
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

