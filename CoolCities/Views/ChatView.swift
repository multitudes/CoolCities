//
//  ChatView.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//
//
//  ChatView.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI

struct ChatView: View {
  let landmark: Landmark
  @StateObject private var generator: ItineraryGenerator = ItineraryGenerator()
  @State private var requestedItinerary: Bool = false
  @State private var promptText: String = ""
  @State private var llmResponse: String = ""
  @State private var isLoading: Bool = false
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        // 1. Title
        Text(landmark.name)
          .padding(.top, 70)
          .font(.largeTitle)
          .fontWeight(.bold)
        
        // 3. LLM Response View
        if isLoading {
          ProgressView()
            .frame(maxWidth: .infinity)
        } else if !generator.response.isEmpty {
          Text(generator.response)
            .padding()
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(8)
        }
        
        Spacer()
      }
      .padding(.horizontal)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .safeAreaInset(edge: .bottom) {
      VStack {
        // 2. User Input TextField
        TextField("Ask about \(landmark.name)...", text: $promptText)
          .textFieldStyle(.roundedBorder)
          .padding()
        
        // 4. Button to trigger LLM call
        ItineraryButton {
          isLoading = true
          Task {
            do {
              await generator.generateItinerary(prompt: promptText)
              isLoading = false
              promptText = ""
            }
          }
        }
      }
      .background(.ultraThinMaterial.opacity(0.50))
    }
    .ignoresSafeArea(edges: .top)
    .task {
      // MARK: - [CODE-ALONG] Chapter 1.6.2: Create the generator when the view appears
      // MARK: - [CODE-ALONG] Chapter 6.1.2: Pre-warm the model when the view appears
      
    }
  }
}

#Preview {
  let mock = Landmark(
    id: 1,
    name: "Berlin",
    continent: "Europe",
    description: "A longer description for previews.",
    shortDescription: "A short description used for previews.",
    latitude: 48.8566,
    longitude: 2.3522,
    span: 0.1
  )
  return ChatView(landmark: mock)
}



struct ItineraryButton: View {
  @State private var showButton: Bool = false
  let closure: () async throws -> Void
  
  var body: some View {
    VStack {
      Button {
        showButton = false
        Task { @MainActor in
          try await closure()
          showButton = true
        }
      }
      label: {
        Label("Generate Answer", systemImage: "sparkles")
          .fontWeight(.bold)
          .padding()
      }
      .buttonStyle(.bordered)
//      .padding()
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

#Preview {
  ItineraryButton {
    print("Done")
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
  
//  func headerStyle(landmark: Landmark) -> some View {
//    modifier(HeaderStyle(landmark: landmark))
//  }
}
//
//struct HeaderStyle: ViewModifier {
//  let landmark: Landmark
//  
//  func body(content: Content) -> some View {
//    content
//      .background(alignment: .top) {
//        ItineraryHeader(destination: landmark)
//      }
////      .frame(maxWidth: .infinity)
//  }
//}

