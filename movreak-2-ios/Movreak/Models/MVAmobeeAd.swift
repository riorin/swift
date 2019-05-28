//
//	MVAmobeeAd.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class MVAmobeeAd: NSObject, Mappable {

	var adSpace: String?
	var partner: String?
	var refreshInterval: Int?
	var serverURL: String?

    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
		adSpace <- map["adSpace"]
		partner <- map["partner"]
		refreshInterval <- map["refreshInterval"]
		serverURL <- map["serverURL"]
		
	}
}
