//
//	MVTheaterDetail.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import ObjectMapper


class MVTheaterDetail: NSObject, Mappable {

	var odatametadata: String?
	var theaters: [MVTheater] = []


    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
		odatametadata <- map["odata.metadata"]
		theaters <- map["value"]
	}

}
