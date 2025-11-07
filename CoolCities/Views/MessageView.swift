// 
//  MessageView.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI

struct MessageView: View {
  let error: Error?
  let landmark: Landmark
  let message: String?
  
  init(error: Error? = nil, landmark: Landmark, message: String? = nil) {
    self.error = error
    self.landmark = landmark
    self.message = message
  }
  
  var body: some View {
    VStack {
      Spacer()
      if let error {
        Text("\(error.localizedDescription)")
          .foregroundStyle(.red)
          .padding(5)
      } else if let message {
        Text("\(message)")
          .foregroundStyle(.black)
          .font(.title3)
          .padding(15)
      }
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(alignment: .top) {
      ItineraryHeader(destination: landmark)
        .opacity(0.6)
    }
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
  MessageView(landmark: mock, message: "This is a sample message to display to the user." )
}
