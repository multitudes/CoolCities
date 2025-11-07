// 
//  ItineraryHeader.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI


struct ItineraryHeader: View {
  var body: some View {
    ZStack(alignment: .topLeading) {
      Image("background")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .clipped()
      Image("background")
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
    ItineraryHeader()
}
