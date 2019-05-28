//
//	MVProfile.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport
//

import Foundation
import Realm
import RealmSwift
import ObjectMapper


class MVProfile: MVUser {
    
    dynamic var birthday: Date?
    dynamic var deviceToken: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var location: String?
    dynamic var movieGenre: String?
    dynamic var movreakOS: String?
    dynamic var movreakType: String?
    dynamic var movreakVersion: String?
    dynamic var pathUserID: String?
    dynamic var political: String?
    dynamic var preferredUsername: String?
    dynamic var providerName: String?
    dynamic var religion: String?
    dynamic var timeZone: String?
    dynamic var udid: String?
    dynamic var url: String?
    dynamic var utcOffset: String?
    dynamic var verifiedEmail: String?
    
    // MARK: - Requireds
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        if about == nil { about <- map["description"] }
        birthday <- (map["birthday"], DateTransform())
        if coverImageUrl == nil { coverImageUrl <- map["coverImage"] }
        if createdDate == nil { createdDate <- (map["createdDate"], DateTransform()) }
        deviceToken <- map["deviceToken"]
        if displayName == nil { displayName <- map["displayName"] }
        if email == nil { email <- map["email"] }
        firstName <- map["firstName"]
        if gender == nil { gender <- map["gender"] }
        lastName <- map["lastName"]
        location <- map["location"]
        movieGenre <- map["MovieGenre"]
        movreakOS <- map["MovreakOS"]
        movreakType <- map["MovreakType"]
        movreakVersion <- map["MovreakVersion"]
        pathUserID <- map["PathUserID"]
        if photoUrl == nil { photoUrl <- map["photo"] }
        political <- map["political"]
        preferredUsername <- map["preferredUsername"]
        providerName <- map["providerName"]
        religion <- map["religion"]
        timeZone <- map["timeZone"]
        udid <- map["UDID"]
        url <- map["url"]
        if userIdentifier == nil { userIdentifier <- map["identifier"] }
        utcOffset <- map["utcOffset"]
        verifiedEmail <- map["verifiedEmail"]
        
        let r = try! Realm()
        if let object = r.object(ofType: MVProfile.self, forPrimaryKey: userProfileID) {
            for property in objectSchema.properties {
                if property == objectSchema.primaryKeyProperty { continue }
                if self.value(forKey: property.name) == nil {
                    self.setValue(object.value(forKey: property.name), forKey: property.name)
                }
            }
        }
	}
}

extension MVProfile {
    
    func jsonString() -> String {
        var json: [String: Any] = [:]
        
        if let authProvider = authProvider {
            json["AuthProvider"] = authProvider
        }
        if let facebookID = facebookID {
            json["FacebookID"] = facebookID
        }
        if let movieGenre = movieGenre {
            json["MovieGenre"] = movieGenre
        }
        if let movreakOS = movreakOS {
            json["MovreakOS"] = movreakOS
        }
        if let movreakType = movreakType {
            json["MovreakType"] = movreakType
        }
        if let movreakVersion = movreakVersion {
            json["MovreakVersion"] = movreakVersion
        }
        if let pathUserID = pathUserID {
            json["PathUserID"] = pathUserID
        }
        if let preferedCity = preferedCity {
            json["PreferedCity"] = preferedCity
        }
        if let preferedCountry = preferedCountry {
            json["PreferedCountry"] = preferedCountry
        }
        if let preferedTheater = preferedTheater.value {
            json["PreferedTheater"] = preferedTheater
        }
        if let preferedTheaterName = preferedTheaterName {
            json["PreferedTheaterName"] = preferedTheaterName
        }
        if let twitterUserName = twitterUserName {
            json["TwitterUserName"] = twitterUserName
        }
        if let udid = udid {
            json["UDID"] = udid
        }
        if let userName = userName {
            json["UserName"] = userName
        }
        json["UserProfileID"] = userProfileID
        if let aboutMe = about {
            json["aboutMe"] = aboutMe
        }
        if let birthday = birthday {
            json["birthday"] = birthday.format(with: "dd/MM/yyyy")
        }
        if let coverImageUrl = coverImageUrl {
            json["coverImage"] = coverImageUrl
        }
        if let createdDate = createdDate {
            json["createdDate"] = createdDate.format(with: "yyyy-MM-dd'T'HH:mm:ss")
        }
        if let description = about {
            json["description"] = description
        }
        if let deviceToken = deviceToken {
            json["deviceToken"] = deviceToken
        }
        if let displayName = displayName {
            json["displayName"] = displayName
        }
        if let email = email {
            json["email"] = email
        }
        if let firstName = firstName {
            json["firstName"] = firstName
        }
//        if let friendsCount = friendsCount {
//            json["friendsCount"] = friendsCount
//        }
        if let gender = gender {
            json["gender"] = gender
        }
        if let identifier = userIdentifier {
            json["identifier"] = identifier
        }
        if let lastName = lastName {
            json["lastName"] = lastName
        }
        if let location = location {
            json["location"] = location
        }
        if let photo = photoUrl {
            json["photo"] = photo
        }
        if let political = political {
            json["political"] = political
        }
        if let preferredUsername = preferredUsername {
            json["preferredUsername"] = preferredUsername
        }
        if let providerName = providerName {
            json["providerName"] = providerName
        }
        if let religion = religion {
            json["religion"] = religion
        }
        if let timeZone = timeZone {
            json["timeZone"] = timeZone
        }
        if let url = url {
            json["url"] = url
        }
        if let utcOffset = utcOffset {
            json["utcOffset"] = utcOffset
        }
        if let verifiedEmail = verifiedEmail {
            json["verifiedEmail"] = verifiedEmail
        }
        
        json = [
            "profile": json,
            "stat": "ok"
        ]
        
        var jsonString = ""
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            if let string = String(data: data, encoding: .utf8) {
                jsonString = string
            }
        }
        
        return jsonString
    }
    
    func preferencesJsonString() -> String {
        var json: [String: Any] = [:]
        
        if let preferedTheater = preferedTheater.value {
            json["PreferedTheater"] = preferedTheater
        }
        if let preferedTheaterName = preferedTheaterName {
            json["PreferedTheaterName"] = preferedTheaterName
        }
        if let preferedCity = preferedCity {
            json["PreferedCity"] = preferedCity
        }
        if let preferedCountry = preferedCountry {
            json["PreferedCountry"] = preferedCountry
        }
        if let movieGenre = movieGenre {
            json["MovieGenre"] = movieGenre
        }
        json["UserProfileID"] = userProfileID
        if let userName = userName {
            json["UserName"] = userName
        }
        if let userIdentifier = userIdentifier {
            json["identifier"] = userIdentifier
        }
        
        json = [
            "profile": json,
            "stat": "ok"
        ]
        
        var jsonString = ""
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            if let string = String(data: data, encoding: .utf8) {
                jsonString = string
            }
        }
        
        return jsonString
    }
}
