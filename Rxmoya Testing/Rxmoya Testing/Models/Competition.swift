//
//  Competition.swift
//  Rxmoya Testing
//
//  Created by Rio Rinaldi on 23/01/19.
//  Copyright © 2019 Rio Rinaldi. All rights reserved.
//

import Foundation

struct Competition : Codable {
    let id : Int?
    let api_id : String?
    let name : String?
    let long_name : String?
    let order : Int?
    let is_default : Int?
    let slug : String?
    let published_at : String?
    let created_at : String?
    let updated_at : String?
    let schedule_banner : String?
    let schedule_banner_type : Int?
    let schedule_banner_info : String?
    let standing_banner : String?
    let standing_banner_type : Int?
    let standing_banner_info : String?
    let published : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case api_id = "api_id"
        case name = "name"
        case long_name = "long_name"
        case order = "order"
        case is_default = "is_default"
        case slug = "slug"
        case published_at = "published_at"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case schedule_banner = "schedule_banner"
        case schedule_banner_type = "schedule_banner_type"
        case schedule_banner_info = "schedule_banner_info"
        case standing_banner = "standing_banner"
        case standing_banner_type = "standing_banner_type"
        case standing_banner_info = "standing_banner_info"
        case published = "published"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        api_id = try values.decodeIfPresent(String.self, forKey: .api_id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        long_name = try values.decodeIfPresent(String.self, forKey: .long_name)
        order = try values.decodeIfPresent(Int.self, forKey: .order)
        is_default = try values.decodeIfPresent(Int.self, forKey: .is_default)
        slug = try values.decodeIfPresent(String.self, forKey: .slug)
        published_at = try values.decodeIfPresent(String.self, forKey: .published_at)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
        schedule_banner = try values.decodeIfPresent(String.self, forKey: .schedule_banner)
        schedule_banner_type = try values.decodeIfPresent(Int.self, forKey: .schedule_banner_type)
        schedule_banner_info = try values.decodeIfPresent(String.self, forKey: .schedule_banner_info)
        standing_banner = try values.decodeIfPresent(String.self, forKey: .standing_banner)
        standing_banner_type = try values.decodeIfPresent(Int.self, forKey: .standing_banner_type)
        standing_banner_info = try values.decodeIfPresent(String.self, forKey: .standing_banner_info)
        published = try values.decodeIfPresent(Bool.self, forKey: .published)
    }
    
}
