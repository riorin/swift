//
//  weather.swift
//  weather
//
//  Created by Rio Rinaldi on 01/05/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import Foundation

class Weather: Codable {
    let forecast: Forecast
}

struct Forecast: Codable {
    let forecastText: ForecastText
    
    private enum CodingKeys: String, CodingKey {
        case forecastText = "txt_forecast"
    }
}

struct ForecastText: Codable {
    let date: String
    let forecastDays: [ForecastDay]
    
    private enum CodingKeys: String, CodingKey{
        case date
        case forecastDays = "forecastdays"
    }
}

struct ForecastDay: Codable {
    let iconUrl: String
    let day: String
    let description: String
    
    private enum CodingKeys: String, CodingKey{
        case iconUrl = "icon_url"
        case day = "title"
        case description = "fcttext"
    }
}





