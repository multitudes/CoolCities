//
//  WeatherData.swift
//  MediumWeather01
//
//  Created by Laurent Brusa on 29/10/2025.
//

import Foundation
import Charts

enum ViewModelState: Equatable{
  case initial
  case isLoading
  case searchActive
  case isGeolocationRequested
  case locationSelected
  case error(String)
}


/// Used for the Open-Meteo API call. It is matching the query
struct WeatherData {
  let utcOffsetSeconds: Int
  let current: Current
  let hourly: Hourly
  let daily: Daily
  
  struct Current {
    let temperature: Float
    let windspeed: Float
    let weathercode: Float
    let is_day: Float
  }
  
  struct Hourly {
    let time: [Date]
    let temperature_2m: [Float]
    let weather_code: [Float]
    let wind_speed_10m: [Float]
    let is_day: [Float]
  }
  
  struct Daily {
    let time: [Date]
    let weather_code: [Float]
    let temperature_2m_max: [Float]
    let temperature_2m_min: [Float]
  }
}


/// Used for fetch locations from the Geocoding API
struct GeocodingResponse: Codable {
  let results: [Location]?
}


/// This is the array element for the Geocoding API results
struct Location: Codable, Identifiable, Hashable {
  let id: Int
  let name: String
  let admin1: String?
  let country: String?
  let latitude: Double
  let longitude: Double
}


/// Need this to convert the weathercodes I get from the API into human-readable descriptions
enum WeatherDescription: Int, Codable {
  case clearSky = 0
  case mainlyClear = 1
  case partlyCloudy = 2
  case overcast = 3
  case fog = 45
  case depositingRimeFog = 48
  case lightDrizzle = 51
  case moderateDrizzle = 53
  case denseDrizzle = 55
  case lightFreezingDrizzle = 56
  case denseFreezingDrizzle = 57
  case slightRain = 61
  case moderateRain = 63
  case heavyRain = 65
  case lightFreezingRain = 66
  case heavyFreezingRain = 67
  case slightSnowFall = 71
  case moderateSnowFall = 73
  case heavySnowFall = 75
  case snowGrains = 77
  case slightRainShowers = 80
  case moderateRainShowers = 81
  case violentRainShowers = 82
  case slightSnowShowers = 85
  case heavySnowShowers = 86
  case thunderstormSlight = 95
  case thunderstormSlightHail = 96
  case thunderstormHeavyHail = 99
  
  var description: String {
    switch self {
    case .clearSky:
      return "Clear sky"
    case .mainlyClear:
      return "Mainly clear"
    case .partlyCloudy:
      return "Partly cloudy"
    case .overcast:
      return "Overcast"
    case .fog:
      return "Fog"
    case .depositingRimeFog:
      return "Depositing rime fog"
    case .lightDrizzle:
      return "Light drizzle"
    case .moderateDrizzle:
      return "Moderate drizzle"
    case .denseDrizzle:
      return "Dense drizzle"
    case .lightFreezingDrizzle:
      return "Light freezing drizzle"
    case .denseFreezingDrizzle:
      return "Dense freezing drizzle"
    case .slightRain:
      return "Slight rain"
    case .moderateRain:
      return "Moderate rain"
    case .heavyRain:
      return "Heavy rain"
    case .lightFreezingRain:
      return "Light freezing rain"
    case .heavyFreezingRain:
      return "Heavy freezing rain"
    case .slightSnowFall:
      return "Slight snowfall"
    case .moderateSnowFall:
      return "Moderate snowfall"
    case .heavySnowFall:
      return "Heavy snowfall"
    case .snowGrains:
      return "Snow grains"
    case .slightRainShowers:
      return "Slight rain showers"
    case .moderateRainShowers:
      return "Moderate rain showers"
    case .violentRainShowers:
      return "Violent rain showers"
    case .slightSnowShowers:
      return "Slight snow showers"
    case .heavySnowShowers:
      return "Heavy snow showers"
    case .thunderstormSlight:
      return "Thunderstorm (slight or moderate)"
    case .thunderstormSlightHail:
      return "Thunderstorm with slight hail"
    case .thunderstormHeavyHail:
      return "Thunderstorm with heavy hail"
    }
  }
}


/// Data model to use in the current and todays tabs
struct CurrentViewWeather: Codable, Identifiable {
  var id = UUID()
  let locationName: String
  let regionName: String?
  let countryName: String?
  let date: Date
  let utcOffsetSeconds: Int
  let weatherDescription: WeatherDescription
  let temperatureCelsius: Float
  let windSpeedKmh: Float
  let isDay: Bool
}


/// Data model to use in the weekly tab
struct WeeklyViewWeather: Codable, Identifiable {
  var id = UUID()
  let locationName: String
  let regionName: String?
  let countryName: String?
  let date: Date
  let utcOffsetSeconds: Int
  let weatherDescription: WeatherDescription
  let maxTemperatureCelsius: Float
  let minTemperatureCelsius: Float
}
