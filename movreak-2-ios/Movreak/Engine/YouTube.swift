//
//  YouTube.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/24/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class YouTube: NSObject {

    class var shared: YouTube {
        struct Static {
            static let instance: YouTube = YouTube()
        }
        return Static.instance
    }
    
    func videoDetail(with youtubeVideoID: String, completion: @escaping MovreakCompletion<JSON>) -> Request {
        
        let urlString = String(format: kYouTubeVideoDetailFormatUrl, youtubeVideoID)
        let request = Alamofire.request(urlString)
            .responseData { (response) in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(data: value)
                    completion(json, nil)
                    
                case .failure(let error):
                    completion(nil, error)
                }
        }
        
        return request
    }
}
