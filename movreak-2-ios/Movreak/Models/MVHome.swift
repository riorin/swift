//
//	MVHome.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class MVHome: NSObject, Mappable {

    var cards: [MVCard] = []
    var links: [MVCard] = []
    var amobeeAd: MVAmobeeAd?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        cards <- map["MainSections"]
        links <- map["LinkSections"]
        amobeeAd <- map["AmobeeAd"]
    }
}
