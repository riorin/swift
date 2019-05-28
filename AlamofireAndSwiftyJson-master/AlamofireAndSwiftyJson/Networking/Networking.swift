//
//  Networking.swift
//  AlamofireAndSwiftyJson
//
//  Created by tolga iskender on 11.08.2018.
//  Copyright © 2018 tolga iskender. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var beritaArray : [BeritaModel] = []

class Networking {
  
    static func getData (basarili: @escaping () -> Void) {
     
        let url =  "\(Utilities.urlString)country=\(Utilities.country)&apiKey=\(Utilities.apiKey)"
        Alamofire.request(url, method: .get).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let articles = json["articles"]
                articles.array?.forEach({ (result) in
                    let sources = result["source"]
                    let Datas = BeritaModel(penerbitBerita: sources["name"].stringValue,
                                           tanggalBerita: result["publishedAt"].stringValue,
                                           gambarBerita: result["urlToImage"].stringValue,
                                           judulBerita: result["title"].stringValue,
                                           isiBerita: result["description"].stringValue,
                                           totalResult: json["totalResults"].stringValue)
                    beritaArray.append(Datas)
                })
                basarili()
            case .failure(let error):
                print(error)
            }
        }
    }
}
