//
//  URLExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/20/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation

extension URL {
    
    var queryItems: [String: String]? {
        var dictionary: [String: String] = [:]
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems {
            for queryItem in queryItems {
                if let value = queryItem.value {
                    dictionary[queryItem.name] = value
                }
            }
        }
        return dictionary
    }
}
