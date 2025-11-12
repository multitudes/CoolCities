// 
//  ItineraryGeneration.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//
import Foundation
import FoundationModels
import Observation
import Combine


@MainActor
final class ItineraryGenerator : ObservableObject {
  
  @Published var response: String = ""
  var error: Error?
  let landmark: Landmark? = nil
  
  @ObservationIgnored
  private var session: LanguageModelSession
  private(set) var itineraryContent: String?
  
  init() {
    let instructions = """
        You are a helpful assistant.
        Your job is to help the user to find nice spots to travel and visit. 
        Please look for places which are cooler in temperature. 
        """
    self.session = LanguageModelSession(instructions: instructions)
  }
  
  func generateItinerary(prompt: String, dayCount: Int = 3) async {
    do {
      let llmresponse = try await session.respond(to: prompt)
      self.response = llmresponse.content
      self.itineraryContent = llmresponse.content
    } catch {
      self.error = error
      print(error)
      self.response = ""
    }
  }
  
  func prewarmModel() {
   }
}

