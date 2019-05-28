//
//  RealmOptionalTransform.swift
//  Movreak-MoyaRxSwift
//
//  Created by Bayu Yasaputro on 3/6/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class RealmOptionalTransform<T: RealmOptionalType>: TransformType {
    typealias Object = RealmOptional<T>
    typealias JSON = Any

    func transformFromJSON(_ value: Any?) -> RealmOptional<T>? {
        let optional = RealmOptional<T>()
        
        if let value = value as? T {
            optional.value = value
        }
        
        return optional
    }
    
    func transformToJSON(_ value: RealmOptional<T>?) -> Any? {
        return value?.value
    }
}
