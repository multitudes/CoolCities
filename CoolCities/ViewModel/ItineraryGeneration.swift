// 
//  ItineraryGeneration.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//
import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class ItineraryGenerator {
  
  var error: Error?
  let landmark: Landmark
  
  private var session: LanguageModelSession
  
  // MARK: - [CODE-ALONG] Chapter 2.3.1: Update to Generable
  // MARK: - [CODE-ALONG] Chapter 4.1.1: Change the property to hold a partially generated Itinerary
  private(set) var itineraryContent: String?
  
  
  // MARK: - [CODE-ALONG] Chapter 5.3.1: Add a property to hold the tool
  
  
  init(landmark: Landmark) {
    self.landmark = landmark
    let instructions = """
        Your job is to create an itinerary for the user.
        Each day needs an activity, hotel and restaurant.
        
        Always include a title, a short description, and a day-by-day plan.
        """
    self.session = LanguageModelSession(instructions: instructions)
    
    
    // MARK: - [CODE-ALONG] Chapter 5.3.2: Initialize LanguageModelSession with Tool
    
  }
  
  func generateItinerary(dayCount: Int = 3) async {
    do {
      let prompt = "Generate a \(dayCount)-day itinerary to \(landmark.name)."
      let response = try await session.respond(to: prompt)
      self.itineraryContent = response.content
    } catch {
      self.error = error
    }
    
    // MARK: - [CODE-ALONG] Chapter 2.3.2: Update to use Generables
    // MARK: - [CODE-ALONG] Chapter 3.3: Update to use one-shot prompting
    // MARK: - [CODE-ALONG] Chapter 4.1.2: Update to use streaming API
    // MARK: - [CODE-ALONG] Chapter 5.3.1: Update the instructions to use the Tool
    // MARK: - [CODE-ALONG] Chapter 5.3.2: Update the LanguageModelSession with the tool
    // MARK: - [CODE-ALONG] Chapter 6.2.1: Update to exclude schema in prompt
    
  }
  
  func prewarmModel() {
    // MARK: - [CODE-ALONG] Chapter 6.1.1: Add a function to pre-warm the model
  }
}
