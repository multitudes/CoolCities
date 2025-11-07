// 
//  LocationInfoHeaderView.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 01/11/2025.
//

import SwiftUI


struct TodayInfoHeaderView: View {
  var todaysWeather: [CurrentViewWeather]
  
  var body: some View {
    // Location Info
    if let first = todaysWeather.first {
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
      .padding(.vertical, 20)
    }
  }
}

#Preview("LocationInfoHeaderView") {
  let hour = 0
  let date = Calendar.current.date(byAdding: .hour, value: hour, to: Date())!
  
  let mockHourly: [CurrentViewWeather] = (0..<24).map { hour in
    CurrentViewWeather(
      locationName: "Mountain View",
      regionName: "California",
      countryName: "United States",
      date: date,
      utcOffsetSeconds: -28800,
      weatherDescription: .clearSky,
      temperatureCelsius: Float.random(in: 4...10),
      windSpeedKmh: Float.random(in: 2...20),
      isDay: true,
    )
  }
  TodayInfoHeaderView(todaysWeather: mockHourly)
}
