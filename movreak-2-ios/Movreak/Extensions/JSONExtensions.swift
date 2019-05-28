//
//  JSONExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    
    var movreakError: NSError {
        
        var errorMessage = "Ooops!"
        if let message = self["Message"].string { errorMessage = message }
        let error = NSError(domain: "MOVREAK", code: 200, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        
        return error
    }
}
