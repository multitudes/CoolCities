//
//  TabView3.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI
import FoundationModels

struct TabView3: View {
  
  private let model = SystemLanguageModel.default
  
  var body: some View {
    NavigationStack {
      VStack {
        switch model.availability {
        case .available:
          VStack {
            Text("Chat with CoolCities")
              .font(.largeTitle.bold())
              .padding(.top, 40)
            ScrollView{
              Text(lorem)
                .padding()
            }
          }
        case .unavailable(.appleIntelligenceNotEnabled):
          MessageView(
            message: """
                         Trip Planner is unavailable because \
                         Apple Intelligence has not been turned on.
                         """
          )
        default:
          MessageView(
            message: """
                         Trip Planner is unavailable. Try again later.
                         """
          )
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.appBackground.ignoresSafeArea().opacity(0.6))
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  TabView3()
}
