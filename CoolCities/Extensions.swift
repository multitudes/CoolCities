//
//  Extensions.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 31/10/2025.
//

import Foundation
import SwiftUI


extension WeatherDescription {
  func systemImageName(isDay: Bool) -> String {
    switch self {
    case .clearSky, .mainlyClear:
      return isDay ? "sun.max.fill" : "moon.stars.fill"
    case .partlyCloudy:
      return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
    case .overcast:
      return "cloud.fill"
    case .fog, .depositingRimeFog:
      return "cloud.fog.fill"
    case .lightDrizzle, .moderateDrizzle, .denseDrizzle:
      return "cloud.drizzle.fill"
    case .lightFreezingDrizzle, .denseFreezingDrizzle:
      return "cloud.sleet.fill"
    case .slightRain, .moderateRain:
      return "cloud.rain.fill"
    case .heavyRain:
      return "cloud.heavyrain.fill"
    case .lightFreezingRain, .heavyFreezingRain:
      return "cloud.sleet.fill"
    case .slightSnowFall, .moderateSnowFall, .heavySnowFall, .snowGrains:
      return "snow"
    case .slightRainShowers, .moderateRainShowers, .violentRainShowers:
      return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
    case .slightSnowShowers, .heavySnowShowers:
      return "cloud.snow.fill"
    case .thunderstormSlight, .thunderstormSlightHail, .thunderstormHeavyHail:
      return "cloud.bolt.rain.fill"
    }
  }
}

extension Color {
  static let appBackground = Color(UIColor { traits in
    if traits.userInterfaceStyle == .dark {
      return UIColor(red: 0.1, green: 0.2,blue: 0.4, alpha: 0.5)
    } else {
      return UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 0.5)
    }})
}
