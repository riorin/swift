//
//	MVNewsList.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class MVNewsList: NSObject, Mappable {

    var count: Int?
    var countTotal: Int?
    var pages: Int?
    var posts: [MVNews] = []
    var query: String?
    var status: String?
    
	var message: String?

    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
        message <- map["message"]
        
        count <- map["news.count"]
        countTotal <- map["news.count_total"]
        pages <- map["news.pages"]
        posts <- map["news.posts"]
        query <- (map["news.query"], JSONTransfrom())
        status <- map["news.status"]
        
	}
    
}
