// 
//  ItineraryHeader.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI



struct ItineraryHeader: View {
  let destination: Landmark
  var body: some View {
    ZStack(alignment: .topLeading) {
      Image(destination.backgroundImageName)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .clipped()
      Image("\(destination.backgroundImageName)-thumb")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .clipped()
        .blur(radius: 16, opaque: true)
        .saturation(1.3)
        .brightness(0.15)
        .mask {
          Rectangle()
            .fill(
              Gradient(stops: [
                .init(color: .clear, location: 0.5),
                .init(color: .white, location: 0.6)
              ])
              .colorSpace(.perceptual)
            )
        }
    }
    .frame(height: 420)
    .compositingGroup()
    .mask {
      Rectangle()
        .fill(
          Gradient(stops: [
            .init(color: .white, location: 0.3),
            .init(color: .clear, location: 1.0)
          ])
          .colorSpace(.perceptual)
        )
    }
    .ignoresSafeArea()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
#if os(iOS)
    .background(Color(uiColor: .systemGray6))
#endif
  }
}

#Preview {
  let mock = Landmark(
    id: 1,
    name: "Sample City",
    continent: "Europe",
    description: "A longer description for previews.",
    shortDescription: "A short description used for previews.",
    latitude: 48.8566,
    longitude: 2.3522,
    span: 0.1
  )
  ItineraryHeader(destination: mock)
}
