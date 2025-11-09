import SwiftUI
import MapKit

struct MapView: View {
  let coordinate: CLLocationCoordinate2D
  let span: MKCoordinateSpan
  
  init(coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)) {
    self.coordinate = coordinate
    self.span = span
  }
  
  var body: some View {
    OverlayMapView(coordinate: coordinate, span: span)
      .frame(height: 220)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .padding()
      .onAppear {
        calculateAndPrintCorners()
      }
  }
  
  private func calculateAndPrintCorners() {
    let center = coordinate
    let latDelta = span.latitudeDelta / 2.0
    let lonDelta = span.longitudeDelta / 2.0
    
    let topLeft = CLLocationCoordinate2D(
      latitude: center.latitude + latDelta,
      longitude: center.longitude - lonDelta
    )
    let topRight = CLLocationCoordinate2D(
      latitude: center.latitude + latDelta,
      longitude: center.longitude + lonDelta
    )
    let bottomLeft = CLLocationCoordinate2D(
      latitude: center.latitude - latDelta,
      longitude: center.longitude - lonDelta
    )
    let bottomRight = CLLocationCoordinate2D(
      latitude: center.latitude - latDelta,
      longitude: center.longitude + lonDelta
    )
    
    print("--- Map Region Corners ---")
    print("Top Left:     lat: \(topLeft.latitude), lon: \(topLeft.longitude)")
    print("Top Right:    lat: \(topRight.latitude), lon: \(topRight.longitude)")
    print("Bottom Left:  lat: \(bottomLeft.latitude), lon: \(bottomLeft.longitude)")
    print("Bottom Right: lat: \(bottomRight.latitude), lon: \(bottomRight.longitude)")
    print("--------------------------")
  }
}

class ImageOverlay: NSObject, MKOverlay {
  let image: UIImage
  let boundingMapRect: MKMapRect
  let coordinate: CLLocationCoordinate2D
  
  init(image: UIImage, rect: MKMapRect) {
    self.image = image
    self.boundingMapRect = rect
    let centerMapPoint = MKMapPoint(x: rect.midX, y: rect.midY)
    self.coordinate = centerMapPoint.coordinate
  }
}

class ImageOverlayRenderer: MKOverlayRenderer {
  override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
    guard let overlay = self.overlay as? ImageOverlay else {
      return
    }
    let rect = self.rect(for: overlay.boundingMapRect)
    
    UIGraphicsPushContext(context)
    overlay.image.draw(in: rect)
    UIGraphicsPopContext()
  }
}

struct OverlayMapView: UIViewRepresentable {
  let coordinate: CLLocationCoordinate2D
  let span: MKCoordinateSpan
  
  // 1. Define the tile overlay with the URL to your tile server.
  // This example uses OpenWeatherMap temperature layer.
  // You need to get an API key from openweathermap.org
  class WeatherTileOverlay: MKTileOverlay {
    override init(urlTemplate: String?) {
      super.init(urlTemplate: urlTemplate)
      self.tileSize = CGSize(width: 256, height: 256)
    }
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
      //      let template = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
      //      let template =
      //      "https://tile.openweathermap.org/maps/2.0/weather/TA2/\(path.z)/\(path.x)/\(path.y).png?appid=385417c76d45ab1972316b6ffd8b6efa"
      let template = "http://maps.openweathermap.org/maps/2.0/weather/TA2/\(path.z)/\(path.x)/\(path.y)?appid=385417c76d45ab1972316b6ffd8b6efa&fill_bound=true&opacity=0.6&palette=-65:821692;-55:821692;-45:821692;-40:821692;-30:8257db;-20:208cec;-10:20c4e8;0:23dddd;10:c2ff28;20:fff028;25:ffc228;30:fc8014"
      print("Tile URL: \(template)")
      return URL(string: template)!
    }
  }
  
  
  // --- Option 2: Local Tile Overlay for Mocking ---
  // This overlay loads a single image from your assets for all tile requests.
  class LocalTileOverlay: MKTileOverlay {
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
      // Use a sample image from your Asset Catalog.
      // Make sure you have an image named "sample_tile" in your assets.
      if let image = UIImage(named: "sample_tile"), let data = image.pngData() {
        result(data, nil)
      } else {
        // Return an empty transparent image if the asset is not found
        let emptyImage = UIGraphicsImageRenderer(size: self.tileSize).image { _ in }
        result(emptyImage.pngData(), nil)
      }
    }
  }
  
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    
    // --- Choose which overlay to use ---
    // To use OpenWeatherMap:
    //    let overlay = WeatherTileOverlay(urlTemplate: nil)
    
    // To use the local mock image:
    let overlay = LocalTileOverlay()
    
    overlay.canReplaceMapContent = false
    mapView.addOverlay(overlay, level: .aboveLabels)
    
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
    let region = MKCoordinateRegion(center: coordinate, span: span)
    uiView.setRegion(region, animated: true)
    
    // Ensure annotation is present
    if uiView.annotations.isEmpty {
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      uiView.addAnnotation(annotation)
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  // 2. The Coordinator is responsible for providing the renderer for the overlay.
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: OverlayMapView
    
    init(_ parent: OverlayMapView) {
      self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if let imageOverlay = overlay as? ImageOverlay {
        let renderer = ImageOverlayRenderer(overlay: imageOverlay)
        renderer.alpha = 0.6 // Set transparency
        return renderer
      }
      if let tileOverlay = overlay as? MKTileOverlay {
        let renderer = MKTileOverlayRenderer(tileOverlay: tileOverlay)
        renderer.alpha = 0.4
        return renderer
      }
      return MKOverlayRenderer(overlay: overlay)
    }
    
  }
}

#Preview("MapView") {
  MapView(coordinate: CLLocationCoordinate2D(latitude: 52.52437, longitude: 13.41053)) // Berlin
}

// 1. Define the tile overlay with the URL to your tile server.
// This example uses OpenWeatherMap temperature layer.
// You need to get an API key from openweathermap.org
//class WeatherTileOverlay: MKTileOverlay {
//  override init(urlTemplate: String?) {
//    super.init(urlTemplate: urlTemplate)
//    // Set the tile size. OpenWeatherMap tiles are 256x256.
//    self.tileSize = CGSize(width: 256, height: 256)
//  }
//  override func url(forTilePath path: MKTileOverlayPath) -> URL {
//    let template =
//    "https://tile.openweathermap.org/maps/2.0/weather/TA2/\(path.z)/\(path.x)/\(path.y).png?appid=385417c76d45ab1972316b6ffd8b6efa"
//
//    print("Tile URL: \(template)")
//    return URL(string: template)!
//  }
//  }

extension MKCoordinateRegion {
  var mapRect: MKMapRect {
    let a = MKMapPoint(CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta / 2, longitude: center.longitude - span.longitudeDelta / 2))
    let b = MKMapPoint(CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta / 2, longitude: center.longitude + span.longitudeDelta / 2))
    return MKMapRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(a.x - b.x), height: abs(a.y - b.y))
  }
}
