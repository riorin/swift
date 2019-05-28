//
//  JSONTransfrom.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/22/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import ObjectMapper

class JSONTransfrom: TransformType {
    public typealias Object = String
    public typealias JSON = Any
    
    func transformFromJSON(_ value: Any?) -> String? {
        
        if let value = value {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                let string = String(data: data, encoding: .utf8)
                return string
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
    
    func transformToJSON(_ value: String?) -> Any? {
        
        if let value = value {
            do {
                if let data = value.data(using: .utf8) {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    return json
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
}
