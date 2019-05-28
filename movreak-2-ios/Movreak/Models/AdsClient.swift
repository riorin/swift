//
//  AdsClient.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/1/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class AdsClient: Object {

    dynamic var address: String?
    dynamic var adsClientID: Int64 = 0
    dynamic var buyHere: String?
    dynamic var contactPerson: String?
    dynamic var createdDate: Date?
    dynamic var deactivatedDate: Date?
    dynamic var isActive: Bool = false
    dynamic var lastModifiedDate: Date?
    dynamic var mobilePhone: String?
    dynamic var name: String?
    dynamic var officePhone: String?
    
    override class func primaryKey() -> String? {
        return "adsClientID"
    }
    
    class func from(json: JSON) -> AdsClient {
        
        let adsClient = AdsClient()
        
        adsClient.address = json["Address"].string
        adsClient.adsClientID = json["AdsClientID"].int64Value
        adsClient.buyHere = json["BuyHere"].string
        adsClient.contactPerson = json["ContactPerson"].string
        adsClient.createdDate = json["CreatedDate"].stringValue.date()
        adsClient.deactivatedDate = json["DeactivatedDate"].stringValue.date()
        adsClient.isActive = json["IsActive"].boolValue
        adsClient.lastModifiedDate = json["LastModifiedDate"].stringValue.date()
        adsClient.mobilePhone = json["MobilePhone"].string
        adsClient.name = json["Name"].string
        adsClient.officePhone = json["OfficePhone"].string
        
        return adsClient
    }
}
