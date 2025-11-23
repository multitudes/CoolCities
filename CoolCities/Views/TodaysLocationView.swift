import SwiftUI
import Charts
import Combine
import MapKit

private struct IdentifiablePlace: Identifiable {
  let id: UUID
  let location: CLLocationCoordinate2D
  init(id: UUID = UUID(), lat: Double, lon: Double) {
    self.id = id
    self.location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }
}

/// The view that displays today's weather for a specific location, including a temperature chart and hourly details.
struct TodaysLocationView: View {
  @EnvironmentObject var viewModel: WeatherViewModel
  var todaysWeather: [CurrentViewWeather]
  var currentWeather: CurrentViewWeather?
  @State private var visibleDate: Date?
  @State private var currentDate = Date()
  //  @State private var region: MKCoordinateRegion
  
  //  private var coordinate: CLLocationCoordinate2D {
  //    region.center
  //  }
  
  var body: some View {
    
    VStack(spacing: 0) {
      
      TodayInfoHeaderView(todaysWeather: todaysWeather)
      
      MapView(coordinate: CLLocationCoordinate2D(
        latitude: viewModel.selectedLocation?.latitude ?? 0.0,
        longitude: viewModel.selectedLocation?.longitude ?? 0.0))
      //        .frame(height: 220)
      
      
      Chart {
        // "Now" marker using the device's current time.
        if let now = nowMarkerDate, let current = currentWeather {
          RuleMark(x: .value("Now", now))
            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
            .foregroundStyle(.red.opacity(0.8))
            .annotation(position: .top, alignment: .leading, spacing: 10) {
              Text("\(current.temperatureCelsius, specifier: "%.0f")° Now")
                .font(.caption.bold())
                .padding(6)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)
            }
        }
        
        ForEach(todaysWeather, id: \.date) { hour in
          LineMark(
            x: .value("Time", hour.date),
            y: .value("Temperature", hour.temperatureCelsius)
          )
          .interpolationMethod(.catmullRom) // Smooth the line
          .foregroundStyle(.orange)
          .symbol(Circle().strokeBorder(lineWidth: 5.5)) // Add circles at data points
          .symbolSize(60)
        }
      }
      .chartXScale(domain: forecastStartDate...forecastEndDate)
      .chartXAxis {
        AxisMarks(values: tickDates(stepHours: 3)) { value in
          AxisGridLine()
          AxisTick()
          AxisValueLabel {
            if let date = value.as(Date.self) {
              Text(axisDateFormatter.string(from: date))
            }
          }
        }
        
      }
      .chartYScale(domain: yAxisRange)
      .chartYAxis {
        // Show labels every 2 degrees Celsius
        AxisMarks(values: .stride(by: 2)) { value in
          AxisGridLine()
          AxisTick()
          AxisValueLabel() {
            if let temp = value.as(Double.self) {
              Text("\(Int(temp))°C")
            }
          }
        }
      }
      .chartYAxisLabel("Temperature", position: .trailing, alignment: .center)
      .chartXAxisLabel("Time (24-Hour)", position: .bottom, alignment: .center)
      // Set a fixed height for the chart
      .frame(minHeight: 250)
      .padding()
      
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 12) {
          ForEach(todaysWeather, id: \.date) { currentViewWeather in
            
            VStack(spacing: 5) {
              VStack {
                // Format the time text using the location's timezone.
                Text("At \(axisDateFormatter.string(from: currentViewWeather.date))")
                  .font(.callout.bold())
                  .foregroundColor(.white)
                
                Text(currentViewWeather.locationName)
                  .font(.headline.bold())
                  .foregroundColor(.white)
                
                if let region = currentViewWeather.regionName, let country = currentViewWeather.countryName {
                  Text("\(region), \(country)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                }
              }
              .padding(.top, 10)
              
              // Main Weather Info
              HStack(spacing: 20) {
                Image(systemName: currentViewWeather.weatherDescription.systemImageName(isDay: currentViewWeather.isDay))
                  .font(.largeTitle)
                  .symbolRenderingMode(.multicolor)
                  .shadow(radius: 5)
                
                Text("\(currentViewWeather.temperatureCelsius, specifier: "%.0f")°")
                  .font(.largeTitle.weight(.thin))
                  .foregroundColor(.white)
              }
              
              // Weather Description
              Text(currentViewWeather.weatherDescription.description)
                .font(.title2)
                .foregroundColor(.white)
              
              // Details (Wind speed)
              HStack {
                Image(systemName: "wind")
                Text("Wind")
                Spacer()
                Text("\(currentViewWeather.windSpeedKmh, specifier: "%.1f") km/h")
              }
              .font(.headline)
              .padding(.horizontal)
              .foregroundColor(.white.opacity(0.9))
              .background(.white.opacity(0.2))
              .cornerRadius(10)
              
            }
            .padding([.top,.bottom], 10)
            .padding(.horizontal, 15)
            .frame(minHeight: 100)
            .background(
              LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue]),
                startPoint: .top,
                endPoint: .bottom
              )
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
            .id(currentViewWeather.date)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .ignoresSafeArea()
        }
        .padding()
        .scrollTargetBehavior(.paging)
      }
      .scrollPosition(id: $visibleDate, anchor: .center)
    }
    Spacer()
    
    
      .onAppear {
        visibleDate = todaysWeather.first?.date
        scrollToNow(animated: false) // initial snap
      }
    // resnap when time advances / timezone changes
      .onChange(of: nowMarkerDate) {
        scrollToNow()
      }
      .onReceive(timer) { newDate in
        print("Timer fired at \(newDate)")
        currentDate = newDate
      }
  }
  
  
  /// Create a timer that fires every 2 minutes (120 seconds).
  private let timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()
  
  /// Create a timezone object from the weather data's offset.
  private var timeZone: TimeZone {
    TimeZone(secondsFromGMT: todaysWeather.first?.utcOffsetSeconds ?? 0) ?? .current
  }
  
  /// Calendar adjusted to the location's timezone.
  private var calendar: Calendar {
    var cal = Calendar.current
    cal.timeZone = timeZone
    return cal
  }
  
  /// The start of the 24-hour forecast period.
  private var forecastStartDate: Date {
    todaysWeather.first?.date ?? Date()
  }
  
  
  /// The end of the 24-hour forecast period.
  private var forecastEndDate: Date {
    calendar.date(byAdding: .hour, value: 24, to: forecastStartDate)!
  }
  
  /// This was a bit tricky - the weqther needs to account for the location's timezone,
  /// but the chart x axis is in UTC time. There is a conversion to be made
  private var nowMarkerDate: Date? {
    let now = currentDate
    let localComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
    var utcCalendar = Calendar.current
    utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return utcCalendar.date(from: localComponents)
  }
  
  /// The timezone of the xaxis is in UTC, so we need a date formatter that reflects that.
  private var axisDateFormatter: DateFormatter {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "HH:mm"
    f.timeZone = TimeZone(secondsFromGMT: 0)
    return f
  }
  
  /// Generate tick dates for the x axis at specified hour intervals.
  private func tickDates(stepHours: Int = 3) -> [Date] {
    guard stepHours > 0 else { return [] }
    var dates: [Date] = []
    var current = forecastStartDate
    let end = forecastEndDate
    while current <= end {
      dates.append(current)
      guard let next = calendar.date(byAdding: .hour, value: stepHours, to: current) else { break }
      current = next
    }
    return dates
  }
  
  /// computed y-axis range with ±8°C padding
  private var yAxisRange: ClosedRange<Double> {
    let temps = todaysWeather.map { Double($0.temperatureCelsius) }
    guard let minT = temps.min(), let maxT = temps.max() else { return -20.0...40.0 }
    var lower = minT - 8.0
    var upper = maxT + 8.0
    // ensure non-zero span
    if lower >= upper {
      lower = lower - 1.0
      upper = upper + 1.0
    }
    return lower...upper
  }
  
  
  /// I have an array of weather data and a target date. I need to find the closest date in the array to the target date.
  /// - Parameters:
  ///   - target:The date as a reference point.
  ///   - weatherData: my hourly weather data array.
  /// - Returns: the weatherdata instance with the closest date to the target date.
  private func findClosestDate(to target: Date?, in weatherData: [CurrentViewWeather]) -> Date? {
    guard let t = target else { return weatherData.first?.date }
    return weatherData.min(by: {
      abs($0.date.timeIntervalSince(t)) < abs($1.date.timeIntervalSince(t))
    })?.date
  }
  
  /// The horizontal scroll view should snap to the closest hour to "now".
  /// - Parameter animated: If true, animate the scroll.
  private func scrollToNow(animated: Bool = true) {
    guard !todaysWeather.isEmpty else { return }
    let closest = findClosestDate(to: nowMarkerDate, in: todaysWeather) ?? todaysWeather.first!.date
    if animated {
      withAnimation { visibleDate = closest }
    } else {
      visibleDate = closest
    }
  }
}

func createMockDate(hour: Int, minute: Int = 0) -> Date {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
  let components = DateComponents(year: 2025, month: 11, day: 2, hour: hour, minute: minute)
  return calendar.date(from: components) ?? Date()
}


#Preview("TodaysLocationView") {
  @ObservedObject var viewModel: WeatherViewModel = WeatherViewModel()
  let berlinCenter = CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405)
  let previewRegion = MKCoordinateRegion(center: berlinCenter, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
  
  let mockWeatherData: [CurrentViewWeather] = (0...23).map { hour in
    let date = createMockDate(hour: hour)
    let halfHour = Double(hour) / 2.0
    let sinTerm = sin(Double(hour) / 4.0)
    let temp = 13.0 - halfHour + (sinTerm * 2.0)
    return CurrentViewWeather(
      locationName: "Berlin",
      regionName: "Berlin",
      countryName: "Germany",
      date: date,
      utcOffsetSeconds: 3600,
      weatherDescription: .overcast,
      temperatureCelsius: Float(temp),
      windSpeedKmh: Float.random(in: 6.0...8.0),
      isDay: true
    )
  }
  
  let mockCurrentWeather = CurrentViewWeather(
    locationName: "Berlin",
    regionName: "Berlin",
    countryName: "Germany",
    date: createMockDate(hour: 9, minute: 15),
    utcOffsetSeconds: 3600,
    weatherDescription: .partlyCloudy,
    temperatureCelsius: 11.6,
    windSpeedKmh: 7.1,
    isDay: true,
  )
  
  TodaysLocationView(todaysWeather: mockWeatherData, currentWeather: mockCurrentWeather)
    .environmentObject(WeatherViewModel())
}
