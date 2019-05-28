//
//  RequestToken.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 05/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import Foundation

struct RequestToken: Codable {
    
    var success: Bool
    var expires_at: String
    var request_token: String
}
