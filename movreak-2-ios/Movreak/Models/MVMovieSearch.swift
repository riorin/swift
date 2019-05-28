//
//  MVMovieSearch.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/18/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import ObjectMapper


class MVMovieSearch: NSObject, Mappable {

    var movies: [MVMovie] = []
    
    var status: String?
    var message: String?
    var execptionMessage: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        movies <- map["data"]
        
        status <- map["State.Status"]
        message <- map["State.Message"]
        execptionMessage <- map["State.ExecptionMessage"]
        
    }
}
