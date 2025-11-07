// 
//  ChatView.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI

struct ChatView: View {
  let landmark: Landmark
  @State private var itineraryGenerator: ItineraryGenerator?
  @State private var requestedItinerary: Bool = false
  
  var body: some View {
    ScrollView {
      if !requestedItinerary {
        VStack(alignment: .leading, spacing: 16) {
          Text(landmark.name)
            .padding(.top, 150)
            .font(.largeTitle)
            .fontWeight(.bold)
          
          Text(landmark.shortDescription)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      // MARK: - [CODE-ALONG] Chapter 1.6.3: Replace EmptyView with model output
      // MARK: - [CODE-ALONG] Chapter 2.4: Update the Text view with `ItineraryView`
      else {
        EmptyView()
      }
    }
    .scrollDisabled(!requestedItinerary)
    .safeAreaInset(edge: .bottom) {
      // MARK: - [CODE-ALONG] Chapter 1.6.4: Generate itinerary and show the button
      ItineraryButton {
        requestedItinerary = true
      }
      .hidden()
    }
    .task {
      // MARK: - [CODE-ALONG] Chapter 1.6.2: Create the generator when the view appears
      // MARK: - [CODE-ALONG] Chapter 6.1.2: Pre-warm the model when the view appears
      
    }
    .headerStyle(landmark: landmark)
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
  return ChatView(landmark: mock)
}

import SwiftUI

struct ItineraryButton: View {
  @State private var showButton: Bool = false
  let closure: () async throws -> Void
  
  var body: some View {
    VStack {
      Button {
        showButton = false
        Task { @MainActor in
          try await closure()
        }
      }
      label: {
        Label("Generate Itinerary", systemImage: "sparkles")
          .fontWeight(.bold)
          .padding()
      }
      .buttonStyle(.bordered)
      .padding()
      .opacity(showButton ? 1 : 0)
      .animation(
        .easeInOut(duration: 0.5),
        value: showButton
      )
      .onAppear {
        showButton = true
      }
      .transition(.opacity)
    }
    .frame(maxWidth: .infinity, alignment: .bottom)
  }
}

extension View {
  
//  func rationaleStyle() -> some View {
//    modifier(RationaleModifier())
//  }
  
//  func itineraryStyle() -> some View {
//    modifier(ItineraryModifier())
//  }
//  
//  func card() -> some View {
//    modifier(CardModifier())
//  }
//  
//  func tagStyle() -> some View {
//    modifier(TagStyleModifier())
//  }
//  
//  func blurredBackground() -> some View {
//    modifier(BlurredBackgroundModifier())
//  }
  
  func headerStyle(landmark: Landmark) -> some View {
    modifier(HeaderStyle(landmark: landmark))
  }
}

struct HeaderStyle: ViewModifier {
  let landmark: Landmark
  
  func body(content: Content) -> some View {
    content
      .background(alignment: .top) {
        ItineraryHeader(destination: landmark)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
