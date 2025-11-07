import SwiftUI
import MapKit

struct MapView: View {
  let coordinate: CLLocationCoordinate2D
  @State private var region: MKCoordinateRegion

  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    // Initialize region with a reasonable default span around the coordinate
    self._region = State(initialValue: MKCoordinateRegion(
      center: coordinate,
      span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
  }

  var body: some View {
    VStack {
    Map(
      position: .constant(.region(region)),
      interactionModes: [.all]
    ) {
      // Annotation at the specified coordinate
      Annotation("Selected Location", coordinate: coordinate) {
        ZStack {
          Circle().fill(Color.blue).frame(width: 12, height: 12)
          Circle().stroke(Color.white, lineWidth: 2).frame(width: 16, height: 16)
        }
      }
    }
//    .frame(maxWidth: .infinity)
    .frame(height: 220)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
      Spacer()
      }
  }
}

#Preview("MapView") {
  MapView(coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050)) // Berlin
}
