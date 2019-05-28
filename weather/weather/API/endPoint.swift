//
//  endPoint.swift
//  weather
//
//  Created by Rio Rinaldi on 01/05/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import Foundation

protocol Endpoint {
    var baseUrl : String {get}
    var path : String {get}
    var queryItems : [URLQueryItem] {get}
}

enum WeatherEndpoint: Endpoint {
    case tenDayForecast(city: String, state: String)
    
    var baseUrl: String {
        return "https://api.wunderground.com/"
    }
    
    var path: String {
        switch self {
        case .tenDayForecast(let city,let state):
        return "/api/7bc34b8c505c7274/conditions/q/\(state)/\(city).json"
        }
    }
    
    var queryItems: [URLQueryItem] {
        return[]
    }
}

extension Endpoint {
    var urlComponent: URLComponents {
        var component = URLComponents(string: baseUrl)
        component?.path = path
        component?.queryItems = queryItems
        
        return component!
    }
    var request: URLRequest {
        return URLRequest(url: urlComponent.url!)
    }
}





