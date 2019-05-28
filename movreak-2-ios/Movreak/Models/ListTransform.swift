//
//  ListTransform.swift
//  Movreak-MoyaRxSwift
//
//  Created by Bayu Yasaputro on 3/5/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class ListTransform<T: RealmSwift.Object>: TransformType where T: Mappable {
    typealias Object = List<T>
    typealias JSON = Array<Any>
    
    func transformFromJSON(_ value: Any?) -> List<T>? {
        let realmList = List<T>()
        
        if let jsonArray = value as? Array<Any> {
            for item in jsonArray {
                if let realmModel = Mapper<T>().map(JSONObject: item) {
                    realmList.append(realmModel)
                }
            }
        }
        
        return realmList
    }
    
    func transformToJSON(_ value: List<T>?) -> Array<Any>? {
        
        guard let realmList = value, realmList.count > 0 else { return nil }
        
        var resultArray = Array<T>()
        
        for entry in realmList {
            resultArray.append(entry)
        }
        
        return resultArray
    }
}
