import SwiftUI
import CoreLocation


struct GeolocationStatusView: View {
  @ObservedObject var locationManager: LocationManager
  @ObservedObject var weatherViewModel:WeatherViewModel
  
  let location: CLLocation? = nil
  var body: some View {
    VStack {
      Spacer()
      
      VStack(spacing: 20) {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
          VStack {
            if let currentWeather = weatherViewModel.currentWeather {
              CurrentLocationView(currentViewWeather: currentWeather)
              
            } else {
              // Show a loading state while fetching weather.
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                .scaleEffect(1.5)
                .padding(.bottom, 10)
              Text("Fetching Weather...")
                .font(.title.bold())
                .foregroundColor(.primary)
            }
          }
          // Use .task(id:) to trigger the fetch on appear and when the location changes.
          .task(id: locationManager.lastKnownLocation) {
            guard let location = locationManager.lastKnownLocation else { return }
            weatherViewModel.fetchWeatherFor(location: location)
          }
        } else if locationManager.authorizationStatus == .notDetermined {
          // Not Determined: Prompt for permission
          Image(systemName: "location.magnifyingglass")
            .font(.system(size: 60))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, .white.opacity(0.6))
          
          Text("Finding Your Location...")
            .font(.title.bold())
            .foregroundColor(.white)
          
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.5)
          
          Image(systemName: "location.questionmark")
            .font(.system(size: 60))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, .white.opacity(0.6))
          
          Text("Location Permission Needed")
            .font(.title.bold())
            .foregroundColor(.white)
          
          Text("Please grant location access to see local weather.")
            .font(.body)
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.center)
          
        } else {
          // Denied or Restricted: Show error and settings link
          Image(systemName: "location.slash.fill")
            .font(.system(size: 60))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.red.opacity(0.8), .white.opacity(0.6))
          
          Text("Location Access Denied")
            .font(.title.bold())
            .foregroundColor(.white)
          
          Text("To get weather for your current location, please enable location services in your device's settings.")
            .font(.body)
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.center)
          
          Button("Open Settings") {
            // This URL opens the app's settings in the Settings app.
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 10)
          .background(.white.opacity(0.2))
          .foregroundColor(.white)
          .cornerRadius(10)
          .padding(.top)
        }
      }
      .padding(40)
//      .background(
//        LinearGradient(
//          gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
//          startPoint: .top,
//          endPoint: .bottom
//        )
//      )
      .cornerRadius(20)
      .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
      .padding()
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}



#Preview("Authorized (Finding)") {
  let manager = LocationManager()
  manager.authorizationStatus = .authorizedWhenInUse
  return GeolocationStatusView(locationManager: manager, weatherViewModel: WeatherViewModel())
//    .background(Color.appBackground.ignoresSafeArea())
}

#Preview("Not Determined") {
  let manager = LocationManager()
  manager.authorizationStatus = .notDetermined
  return GeolocationStatusView(locationManager: manager, weatherViewModel: WeatherViewModel())
//    .background(Color.appBackground.ignoresSafeArea())
}

#Preview("Denied") {
  let manager = LocationManager()
  manager.authorizationStatus = .denied
  return GeolocationStatusView(locationManager: manager, weatherViewModel: WeatherViewModel())
//    .background(Color.appBackground.ignoresSafeArea())
}

#Preview("Restricted") {
  let manager = LocationManager()
  manager.authorizationStatus = .restricted
  return GeolocationStatusView(locationManager: manager, weatherViewModel: WeatherViewModel())
//    .background(Color.appBackground.ignoresSafeArea())
}
