//
//  RealmExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    
    static func writeAsync(objects: [Object], completion: @escaping Completion) {
        
        let filteredObjects = objects.filter { (object) -> Bool in
            return object.realm == nil
        }
        
        DispatchQueue.global().async {
            let realm = try! Realm()
            
            try! realm.write {
                for object in filteredObjects {
                    realm.add(object, update: true)
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}


import Moya
import RxSwift
import ObjectMapper

extension ObservableType {
    
    func write<T>() -> Observable<T> {
        return self as! Observable<T>
    }
}
