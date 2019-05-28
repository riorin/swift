//
//	MVSearch.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class MVSearch: NSObject, Mappable {

	var movies: [MVMovie] = []
	var theaters: [MVTheater] = []
    
    var status: String?
    var message: String?
    var execptionMessage: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        
		movies <- map["data.Movies"]
		theaters <- map["data.Theaters"]
        
        status <- map["State.Status"]
        message <- map["State.Message"]
        execptionMessage <- map["State.ExecptionMessage"]
		
	}
}
