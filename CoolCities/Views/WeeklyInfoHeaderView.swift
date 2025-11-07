//
//  LocationInfoHeaderView.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 01/11/2025.
//

import SwiftUI


struct WeeklyInfoHeaderView: View {
  var weeklyWeather: [WeeklyViewWeather]
  
  var body: some View {
    // Location Info
    if let first = weeklyWeather.first {
      VStack(spacing: 4) {
        Text(first.locationName)
          .font(.title.bold())
          .foregroundColor(.primary)
        if let region = first.regionName, let country = first.countryName {
          Text("\(region), \(country)")
            .font(.headline)
            .foregroundColor(.primary.opacity(0.8))
        }
      }
      .padding(.vertical, 16)
    }
  }
}


#Preview("WeeklyInfoHeaderView") {
  let mockdayly: [WeeklyViewWeather] = [
    WeeklyViewWeather(
      locationName: "San Francisco",
      regionName: "California",
      countryName: "United States",
      date: Date(),
      utcOffsetSeconds: 3600,
      weatherDescription: .clearSky,
      maxTemperatureCelsius: 22.0,
      minTemperatureCelsius: 12.0,
    ),
      
  ]
  
  WeeklyInfoHeaderView(weeklyWeather: mockdayly)
}
