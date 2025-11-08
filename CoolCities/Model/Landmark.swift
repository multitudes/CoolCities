// 
//  Landmark.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import CoreLocation
import MapKit

struct Landmark: Hashable, Codable, Identifiable {
  var id: Int
  var name: String
  var continent: String
  var description: String
  var shortDescription: String
  var latitude: Double
  var longitude: Double
  var span: Double
  var placeID: String?
  
  var backgroundImageName: String {
    return "\(id)"
  }
  
  var thumbnailImageName: String {
    return "\(id)-thumb"
  }
  
  var locationCoordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: latitude,
      longitude: longitude)
  }
  
  var coordinateRegion: MKCoordinateRegion {
    MKCoordinateRegion(
      center: locationCoordinate,
      span: .init(latitudeDelta: span, longitudeDelta: span)
    )
  }
}

