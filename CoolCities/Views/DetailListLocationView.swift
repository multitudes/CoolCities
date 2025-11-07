// 
//  DetailListLocationView.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 31/10/2025.
//

import SwiftUI


struct DetailListLocationView: View {
  let location: Location
  
  var body: some View {
    
    VStack() {
      Text(location.name)
        .font(.title.bold())
        .foregroundColor(.white)
      
      if let region = location.admin1, let country = location.country {
        Text("\(region), \(country)")
          .font(.headline)
          .foregroundColor(.white.opacity(0.8))
      }
    }
    .padding()
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)
    .listRowInsets(EdgeInsets())
    .frame(maxWidth: .infinity)
    .background(
      LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
        startPoint: .top,
        endPoint: .bottom
      )
    )
    .cornerRadius(20)
    .padding(.vertical, 8)
  }
}



#Preview {
  let mockLocation = Location(
    id: 1,
    name: "San Francisco",
    admin1: "California",
    country: "USA",
    latitude: 37.7749,
    longitude: -122.4194,
  )
  
  DetailListLocationView(location: mockLocation)
    .background(Color.appBackground.ignoresSafeArea())
}
