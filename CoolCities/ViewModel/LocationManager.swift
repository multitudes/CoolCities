// 
//  LocationManager.swift
//  MediumWeather01
//
//  Created by Laurent Brusa on 29/10/2025.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
  @Published var lastKnownLocation: CLLocation?
  
  private let manager = CLLocationManager()
  
  override init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
    self.authorizationStatus = manager.authorizationStatus
  }
  
  func requestLocationAuthorization() {
    // Request authorization only if status is not yet determined
    if manager.authorizationStatus == .notDetermined {
      manager.requestWhenInUseAuthorization()
      print("Requested location authorization...")
    } else if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
      // If already authorized, start updating the location immediately
      manager.requestLocation()
    }
  }
  
  // MARK: - CLLocationManagerDelegate
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let newStatus = manager.authorizationStatus
    DispatchQueue.main.async {
      self.authorizationStatus = newStatus
    }
    // If the status is granted, request the user's current location once
    if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
      manager.requestLocation()
    }
    
    switch manager.authorizationStatus {
    case .authorizedWhenInUse:
      print("Location authorization granted.")
      // You would typically start updating location here: manager.startUpdatingLocation()
    case .denied, .restricted:
      print("Location authorization denied or restricted.")
      // Handle error or show a settings prompt to the user
    case .notDetermined:
      print("Location authorization status: Not Determined.")
    default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    DispatchQueue.main.async {
      self.lastKnownLocation = location
    }
    print("Location Received: \(location.coordinate.latitude), \(location.coordinate.longitude)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager Failed with error: \(error.localizedDescription)")
  }
}
