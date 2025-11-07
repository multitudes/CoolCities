//
//  LocationListView.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 01/11/2025.
//

import SwiftUI

struct LocationListView: View {
  let locations: [Location]
  let selectLocation: (Location) -> Void
  var body: some View {
    List(locations) { location in
      DetailListLocationView(location: location)
        .onTapGesture {
          selectLocation(location)
        }
    }
    .scrollContentBackground(.hidden)    }
}


#Preview {
  let mockLocations = [
    Location(
      id: 1,
      name: "San Francisco",
      admin1: "California",
      country: "USA",
      latitude: 37.7749,
      longitude: -122.4194,
    ),
    Location(
      id: 2,
      name: "San Francisco",
      admin1: "California",
      country: "USA",
      latitude: 37.7749,
      longitude: -122.4194,
    )
  ]
  LocationListView(locations: mockLocations, selectLocation: {_ in })
    .background(Color.appBackground.ignoresSafeArea())
}
