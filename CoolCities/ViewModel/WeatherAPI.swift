// 
//  WeatherAPI.swift
//  AdvancedWeather
//
//  Created by Laurent Brusa on 02/11/2025.
//

import SwiftUI

/// Make sure the URL contains '&format=flatbuffers'
struct WeatherAPI {
  static let geoCoding: String = "https://geocoding-api.open-meteo.com/v1/search"
  static let baseURL: String = "https://api.open-meteo.com/v1/forecast"
  static let defaultWeatherQuery: String = "&daily=weather_code,temperature_2m_max,temperature_2m_min,&hourly=temperature_2m,weather_code,wind_speed_10m,is_day&current=temperature_2m,wind_speed_10m,weather_code,is_day&timezone=auto&format=flatbuffers"
  static func weatherURL(lat: Double, lon: Double) -> String {
    print("URL for query " + baseURL + "?latitude=\(lat)&longitude=\(lon)" + defaultWeatherQuery)
    return  baseURL + "?latitude=\(lat)&longitude=\(lon)" + defaultWeatherQuery
  }
  static private let timeoutInterval: TimeInterval = 10
  
  static var timeoutSession: URLSession {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = timeoutInterval
    config.timeoutIntervalForResource = timeoutInterval
    return URLSession(configuration: config)
  }
}
