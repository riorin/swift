//
//  Path.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import CoreLocation

fileprivate var headers: [String: String] {
    return [
        "User-Agent": "Path/370 CFNetwork/672.1.14 Darwin/14.0.0",
        "X-PATH-DEVICE": "iPhone6,2",
        "X-PATH-PLATFORM": "iOS 7.1",
        "X-PATH-CLIENT": "4.0.2",
        "X-PATH-APP-STATE": "fg",
        "X-PATH-TIMEZONE": "Asia/Jakarta",
        "X-PATH-BUNDLE-ID": "com.path.Path",
        "X-PATH-APP": "shr",
        "Accept": "*/*"
    ]
}

fileprivate var endpointClosure = { (target: Path) -> Endpoint in
    let defaultEndpoint = CGDataProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: headers)
}

let pathProvider = CGDataProvider(endpointClosure: endpointClosure)

enum Path {
    case authenticateUser(String, String)
    case addThought(String, Bool, [Any]?, CLLocation?)
}

extension Path: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.path.com")!
    }
    
    var path: String {
        switch self {
        case .authenticateUser:
            return "/3/user/authenticate"
            
        case .addThought:
            return "/3/moment/add"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .authenticateUser, .addThought:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .authenticateUser, .addThought:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .authenticateUser, .addThought:
            return URLEncoding.default
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        
        var propertyList: [String: Any] = [:]
        
        switch self {
        case .authenticateUser(let username, let password):
            propertyList["login"] = username
            propertyList["password"] = password
            propertyList["reactivate_user"] = true
            
        case .addThought(let thought, let isPrivate, let people, let location):
            propertyList["thought"] = ["body": thought]
            propertyList["private"] = isPrivate ? "true" : "false"
            propertyList["type"] = "thought"
            if let people = people {
                propertyList["people"] = people
            }
            if let location = location {
                propertyList["location"] = location.pathLocation
            }
            
        default:
            break
        }
        
        do {
            let propertyListData = try PropertyListSerialization.data(fromPropertyList: propertyList, format: .binary, options: 0)
            return .upload(.multipart([MultipartFormData(provider: .data(propertyListData), name: "post")]))
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return .request
    }
    
    var validate: Bool {
        return false
    }
}

extension CLLocation {
    
    var pathLocation: [String: String] {
        return [
            "lat": String(format: "%+.6f", coordinate.latitude),
            "lng": String(format: "%+.6f", coordinate.longitude),
        ]
    }
}
