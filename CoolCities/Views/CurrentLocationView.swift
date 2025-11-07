//
//  CurrentlocationView.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 31/10/2025.
//

import SwiftUI


struct CurrentLocationView: View {
  let currentViewWeather: CurrentViewWeather
  
  var body: some View {
    VStack {
      Spacer()
      
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 16) {
          VStack {
            Text(currentViewWeather.locationName)
              .font(.largeTitle.bold())
              .foregroundColor(.white)
            
            if let region = currentViewWeather.regionName, let country = currentViewWeather.countryName {
              Text("\(region), \(country)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            }
          }
          .padding(.bottom, 20)
          
          // Main Weather Info
          HStack(spacing: 20) {
            Image(systemName: currentViewWeather.weatherDescription.systemImageName(isDay: currentViewWeather.isDay))
              .font(.system(size: 80))
              .symbolRenderingMode(.multicolor)
              .shadow(radius: 5)
            
            Text("\(currentViewWeather.temperatureCelsius, specifier: "%.0f")°")
              .font(.system(size: 100, weight: .thin))
              .foregroundColor(.white)
          }
          
          // Weather Description
          Text(currentViewWeather.weatherDescription.description)
            .font(.title2)
            .foregroundColor(.white)
          
          // Details (Wind speed)
          HStack {
            Image(systemName: "wind")
            Text("Wind")
            Spacer()
            Text("\(currentViewWeather.windSpeedKmh, specifier: "%.1f") km/h")
          }
          .font(.headline)
          .foregroundColor(.white.opacity(0.9))
          .padding()
          .background(.white.opacity(0.2))
          .cornerRadius(10)
          
        }
        .padding(30)
        .background(
          LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue]),
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
        .padding()
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  let hour = Int.random(in: 0...23)
  let date = Calendar.current.date(byAdding: .hour, value: hour, to: Date())!

  let mockLocation = CurrentViewWeather(
    locationName: "Cupertino",
    regionName: "California",
    countryName: "United States",
    date: date,
    utcOffsetSeconds: 3600, weatherDescription: .partlyCloudy,
    temperatureCelsius: 22,
    windSpeedKmh: 15.5,
    isDay: true,
  )
  
  CurrentLocationView(currentViewWeather: mockLocation)
    .background(Color.appBackground.ignoresSafeArea().opacity(0.2))
    .background(Image("weather").resizable().opacity(0.6).scaledToFill().ignoresSafeArea())
}
