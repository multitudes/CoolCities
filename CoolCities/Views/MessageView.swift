// 
//  MessageView.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI

struct MessageView: View {
  let error: Error?
  let message: String?
  
  init(error: Error? = nil,  message: String? = nil) {
    self.error = error
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
      ItineraryHeader()
        .opacity(0.6)
    }
  }
}

#Preview {
    MessageView(message: "This is a sample message to display to the user." )
}
