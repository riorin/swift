//
//  DictionaryExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/6/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V>
    {
        var map = Dictionary<K,V>()
        for (k, v) in left {
            map[k] = v
        }
        for (k, v) in right {
            map[k] = v
        }
        return map
    }
}
