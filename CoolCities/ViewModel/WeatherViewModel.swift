//  ViewModel.swift
//  MediumWeather01
//
//  Created by Laurent Brusa on 29/10/2025.
//

import SwiftUI
import Combine
import Foundation
import OpenMeteoSdk
import CoreLocation


/// Main ViewModel for the app
@MainActor final class WeatherViewModel: ObservableObject {
  @Published var state: ViewModelState = .isGeolocationRequested
  @Published var searchText: String = ""
  @Published var locations: [Location] = []
  @Published var selectedLocation: Location? = nil
  @Published var currentWeather: CurrentViewWeather? = nil
  @Published var todaysWeather: [CurrentViewWeather]? = []
  @Published var weeklyWeather: [WeeklyViewWeather]? = []
  @Published var searchTask: Task<Void, Never>? = nil
  
  // MARK: - Public Methods
  
  /// The initial state and behavior when the user taps the geolocation button
  func onGeoLocationTap() {
    print("Geolocation tapped")
    withAnimation(.easeInOut) {
      searchText = ""
      locations = []
      state = .isGeolocationRequested
    }
  }
  
  
  /// called when the user types in the search field
  /// - Parameter query: query description
  func performSearch(for query: String) {
    print("Search started")
    withAnimation(.easeInOut) {
      state = .isLoading
      selectedLocation = nil
      searchTask?.cancel()
      locations = []
    }
    
    if query.count >= 1 {
      searchTask = Task {
        do {
          try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
          guard !Task.isCancelled else { return }
          locations = try await fetchLocations(for: query, count: 5)
          state = .searchActive
        } catch is CancellationError {
          // This is an expected error when the user types quickly and a new search task cancels the previous one.
          print("Search task was cancelled.")
        } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
          // This is another form of cancellation error from the underlying URLSession.
          print("URLSession task was cancelled.")
        } catch {
          // Handle other, unexpected errors.
          print("Error fetching locations: \(error)")
          state = .error("Failed to fetch locations: \(error.localizedDescription)")
          self.locations = []
        }
      }
    } else {
      state = .searchActive
      locations = []
    }
  }
  
  
  /// Geocoding search in the Open-Meteo Geocoding API
  /// - Parameters:
  ///   - query: query is a string of city or region to search for
  ///   - count: How many results i want
  /// - Returns: An array of Location objects matching the query
  func fetchLocations(for query: String, count: Int = 10) async throws -> [Location] {
    var comps = URLComponents(string: WeatherAPI.geoCoding)!
    comps.queryItems = [
      URLQueryItem(name: "name", value: query),
      URLQueryItem(name: "count", value: String(count)),
      URLQueryItem(name: "language", value: "en")
    ]
    let url = comps.url!
    let (data, response) = try await WeatherAPI.timeoutSession.data(from: url)
    //    let (data, response) = try await URLSession.shared.data(from: url)
    guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
      throw URLError(.badServerResponse)
    }
    let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
    return decoded.results ?? []
  }
  
  
  /// When the user selectes a location from the search results
  /// - Parameter location: Latitude and Longitude of the selected location.
  func selectLocation(_ location: Location) {
    state = .isLoading
    selectedLocation = location
    locations = []
    todaysWeather = []
    weeklyWeather = []
    searchTask?.cancel()
    print("Selection ----------------------------")
    print("Location selected: \(location.id)")
    print("Selected location: \(location.name)")
    print("Selected Location Region \(location.admin1 ?? "unknown")")
    print("Selected Location Country \(location.country ?? "unknown")")
    print("Latitude: \(location.latitude), Longitude: \(location.longitude)")
    Task {
      do {
        let weatherData: WeatherData = try await fetchCurrentWeather(lat: location.latitude, lon: location.longitude)
        
        self.currentWeather = createCurrentViewWeather(location: selectedLocation!, weatherData: weatherData)
        self.todaysWeather = createHourlyViewWeather(location: selectedLocation!, weatherData: weatherData)
        self.weeklyWeather = createWeeklyViewWeather(location: selectedLocation!, weatherData: weatherData)
        
        self.state = .locationSelected
      } catch {
        // Handle errors during weather fetch
        state = .error("Failed to fetch current weather: \(error.localizedDescription)")
        self.currentWeather = nil
      }
    }
  }
  
  
  /// Makes an api call to fetch current weather data for given latitude and longitude
  /// - Parameters:
  ///   - lat: latitude of the location
  ///   - lon: longitude of the location
  /// - Returns: A WeatherData object containing current and hourly weather data
  func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherData {
    let urlString = WeatherAPI.weatherURL(lat: lat, lon: lon)
    guard let url = URL(string: urlString) else {
      throw URLError(.badURL)
    }
    
    let responses = try await WeatherApiResponse.fetch(url: url)
    guard let response = responses.first else {
      throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "No weather data received."])
    }
    
    let latitude = response.latitude
    let longitude = response.longitude
    let timezone: String? = response.timezone
    let timezoneAbbreviation: String? = response.timezoneAbbreviation
    let utcOffsetSeconds = response.utcOffsetSeconds
    
    print("\nCoordinates: \(latitude)°N \(longitude)°E")
    print("Timezone: \(timezone ?? "") \(timezoneAbbreviation ?? "")")
    print("Timezone difference to GMT+0: \(utcOffsetSeconds)s")
    
    guard let hourly = response.hourly, let current = response.current, let daily = response.daily else {
      throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Hourly, current, or daily weather data is missing in the response."])
    }
    guard let hourlyTemperature = hourly.variables(at: 0)?.values,
          let hourlyWeatherCode = hourly.variables(at: 1)?.values,
          let hourlyWindSpeed = hourly.variables(at: 2)?.values,
          let hourlyIsDay = hourly.variables(at: 3)?.values else {
      throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Hourly weather variables are missing."])
    }
    
    guard let currentTemperature = current.variables(at: 0)?.value,
          let currentWindspeed = current.variables(at: 1)?.value,
          let currentweathercode = current.variables(at: 2)?.value,
          let currentIsDay = current.variables(at: 3)?.value else {
      throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Current weather variables are missing."])
    }
    
    guard let dailyWeatherCode = daily.variables(at: 0)?.values,
          let dailyTempMax = daily.variables(at: 1)?.values,
          let dailyTempMin = daily.variables(at: 2)?.values else {
      throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Daily weather variables are missing."])
    }
    
    /// Note: The order of weather variables in the URL query and the 'at' indices below need to match!
    let data = WeatherData(
      utcOffsetSeconds: Int(utcOffsetSeconds),
      current: .init(
        temperature: currentTemperature,
        windspeed: currentWindspeed,
        weathercode: currentweathercode,
        is_day: currentIsDay
      ),
      hourly: .init(
        time: hourly.getDateTime(offset: utcOffsetSeconds),
        temperature_2m: hourlyTemperature,
        weather_code: hourlyWeatherCode,
        wind_speed_10m: hourlyWindSpeed,
        is_day: hourlyIsDay
      ),
      daily: .init(
        time: daily.getDateTime(offset: utcOffsetSeconds),
        weather_code: dailyWeatherCode,
        temperature_2m_max: dailyTempMax,
        temperature_2m_min: dailyTempMin
      )
    )
    print("Debug: Finished fetching current weather data.")
    print("---------------------------------------")
    print("State \(state)")
    // Return the constructed WeatherData object directly.
    return data
  }
  
  /// Used inside the geolocation flow to fetch weather for the user's current location
  /// - Parameter location: The last known location is passed to the function
  func fetchWeatherFor(location: CLLocation) {
    state = .isLoading
    Task {
      do {
        // Fetch Weather Data from the API
        let weatherData = try await fetchCurrentWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        self.selectedLocation = try await createLocation(from: location)
        if let selectedLocation = self.selectedLocation {
          self.currentWeather = createCurrentViewWeather(location: selectedLocation, weatherData: weatherData)
          self.todaysWeather = createHourlyViewWeather(location: selectedLocation, weatherData: weatherData)
          self.weeklyWeather = createWeeklyViewWeather(location: selectedLocation, weatherData: weatherData)
        }
        state = .locationSelected
      } catch {
        state = .error("Failed to get weather for current location: \(error.localizedDescription)")
        self.currentWeather = nil
      }
    }
  }
  
  func reset() {
    print("reset")
    withAnimation(.easeInOut) {
      state = .locationSelected
      locations = []
    }
  }
  
  // MARK: - Private Methods
  
  private func resetLocations() {
    locations = []
    searchTask?.cancel()
    state = .searchActive
  }
  
  private func reverseGeocode(location: CLLocation) async throws -> CLPlacemark {
    let geocoder = CLGeocoder()
    guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
      throw GeocodingError.placemarkNotFound
    }
    return placemark
  }
  
  // MARK: - Error Types
  
  /// Used in the reverse geocoding process
  private enum GeocodingError: LocalizedError {
    case placemarkNotFound
    
    var errorDescription: String? {
      switch self {
      case .placemarkNotFound:
        return "Could not find address for location."
      }
    }
  }
  
  /// Converts a raw CLLocation into a structured Location object via reverse geocoding.
  /// - Parameter location: The raw CLLocation obtained from the location manager.
  /// - Returns: A new Location struct containing geocoded details.
  private func createLocation(from location: CLLocation) async throws -> Location {
    
    // Reverse Geocode to get a placemark
    let placemark = try await reverseGeocode(location: location)
    
    return Location(
      id: Int.random(in: 1...10000),
      name: placemark.locality ?? placemark.name ?? "Unknown Location",
      admin1: placemark.administrativeArea,
      country: placemark.country,
      latitude: location.coordinate.latitude,
      longitude: location.coordinate.longitude
    )
  }
  
  /// Creates the UI-ready model for the current weather conditions.
  /// - Parameters:
  ///   - location: The user's geo-coded location details.
  ///   - weatherData: The full raw weather forecast data.
  /// - Returns: A single CurrentViewWeather object.
  private func createCurrentViewWeather(
    location: Location,
    weatherData: WeatherData
  ) -> CurrentViewWeather {
    
    let current = weatherData.current
    
    return CurrentViewWeather(
      locationName: location.name,
      regionName: location.admin1,
      countryName: location.country,
      date: weatherData.hourly.time.first ?? Date(),
      utcOffsetSeconds: weatherData.utcOffsetSeconds,
      weatherDescription: WeatherDescription(rawValue: Int(current.weathercode)) ?? .clearSky,
      temperatureCelsius: current.temperature,
      windSpeedKmh: current.windspeed,
      isDay: current.is_day == 1.0
      )
  }
  
  /// Creates an array of UI-ready models for the hourly forecast (Today's Weather).
  /// - Parameters:
  ///   - location: The user's geo-coded location details.
  ///   - weatherData: The full raw weather forecast data.
  /// - Returns: An array of CurrentViewWeather objects, typically for 24 hours.
  private func createHourlyViewWeather(
    location: Location,
    weatherData: WeatherData
  ) -> [CurrentViewWeather] {
    
    let hourly = weatherData.hourly
    let count = min(24, hourly.time.count)
    
    guard count > 0 else { return [] }
    
    return (0..<count).map { i in
      print("Debug: Creating hourly weather for index \(i)")
      print("Time: \(hourly.time[i])")
      return CurrentViewWeather(
        locationName: location.name,
        regionName: location.admin1,
        countryName: location.country,
        date: hourly.time[i],
        utcOffsetSeconds: weatherData.utcOffsetSeconds,
        weatherDescription: WeatherDescription(rawValue: Int(hourly.weather_code[i])) ?? .clearSky,
        temperatureCelsius: hourly.temperature_2m[i],
        windSpeedKmh: hourly.wind_speed_10m[i],
        isDay: hourly.is_day[i] == 1.0
      )
    }
  }
  
  /// Creates an array of UI-ready models for the weekly forecast.
  /// - Parameters:
  ///   - location: The user's geo-coded location details.
  ///   - weatherData: The full raw weather forecast data.
  /// - Returns: An array of WeeklyViewWeather objects.
  private func createWeeklyViewWeather(
    location: Location,
    weatherData: WeatherData
  ) -> [WeeklyViewWeather] {
    
    let daily = weatherData.daily
    // The loop should be over the actual number of days returned by the API.
    let count = daily.time.count
    
    guard count > 0 else { return [] }
    
    return (0..<count).map { i in
      WeeklyViewWeather(
        locationName: location.name,
        regionName: location.admin1,
        countryName: location.country,
        date: daily.time[i],
        utcOffsetSeconds: weatherData.utcOffsetSeconds,
        weatherDescription: WeatherDescription(rawValue: Int(daily.weather_code[i])) ?? .clearSky,
        maxTemperatureCelsius: daily.temperature_2m_max[i],
        minTemperatureCelsius: daily.temperature_2m_min[i]
      )
    }
  }
}
