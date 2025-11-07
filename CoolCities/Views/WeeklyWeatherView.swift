//
//  WeeklyWeatherView.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 01/11/2025.
//

import SwiftUI
import Charts
import Combine

struct WeeklyWeatherView: View {
  let weeklyWeather: [WeeklyViewWeather]
  var currentWeather: CurrentViewWeather?
  @State private var visibleDate: Date?
  @State private var currentDate = Date()
  
  /// Create a timer that fires every 2 minutes (120 seconds).
  private let timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()
  
  /// Create a timezone object from the weather data's offset.
  private var timeZone: TimeZone {
    TimeZone(secondsFromGMT: weeklyWeather.first?.utcOffsetSeconds ?? 0) ?? .current
  }
  
  /// Calendar adjusted to the location's timezone.
  private var calendar: Calendar {
    var cal = Calendar.current
    cal.timeZone = timeZone
    return cal
  }
  
  /// The start of the 7-day forecast period.
  private var forecastStartDate: Date {
    weeklyWeather.first?.date ?? Date()
  }
  
  /// The end of the 7-day forecast period.
  private var forecastEndDate: Date {
    // Add one day to the last date to ensure the full 7-day range is visible.
    let lastDate = weeklyWeather.last?.date ?? forecastStartDate
    return calendar.date(byAdding: .day, value: 1, to: lastDate)!
  }
  
  /// This was a bit tricky - the weather needs to account for the location's timezone,
  /// but the chart x axis is in UTC time. There is a conversion to be made
  private var nowMarkerDate: Date? {
    let now = currentDate
    let localComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
    var utcCalendar = Calendar.current
    utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return utcCalendar.date(from: localComponents)
  }
  
  /// Date formatter for the x-axis labels (e.g., "Mon", "Tue").
  private var axisDateFormatter: DateFormatter {
    let f = DateFormatter()
    f.dateFormat = "EEE" // Abbreviated weekday
    f.timeZone = timeZone // Use the location's timezone for labels
    return f
  }
  
  /// Generate tick dates for the x axis at specified day intervals.
  private func tickDates(stepDays: Int = 1) -> [Date] {
    guard stepDays > 0, !weeklyWeather.isEmpty else { return [] }
    var dates: [Date] = []
    // Start from the beginning of the first day to align ticks properly.
    var current = calendar.startOfDay(for: forecastStartDate)
    let end = forecastEndDate
    
    while current < end {
      dates.append(current)
      guard let next = calendar.date(byAdding: .day, value: stepDays, to: current) else { break }
      current = next
    }
    return dates
  }
  
  /// computed y-axis range with ±8°C padding
  private var yAxisRange: ClosedRange<Double> {
    let temps = weeklyWeather.map { Double($0.minTemperatureCelsius) } + weeklyWeather.map { Double($0.maxTemperatureCelsius) }
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
  
  @ChartContentBuilder
  private var chartContent: some ChartContent {
    // "Now" marker using the device's current time.
    if let now = nowMarkerDate, let current = weeklyWeather.first {
      RuleMark(x: .value("Now", now))
        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
        .foregroundStyle(.red.opacity(0.8))
        .annotation(position: .top, alignment: .leading, spacing: 10) {
          Text("\(current.minTemperatureCelsius, specifier: "%.0f")° - \(current.maxTemperatureCelsius, specifier: "%.0f")° Today")
            .font(.caption.bold())
            .padding(6)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 2)
        }
    }
    
    ForEach(weeklyWeather, id: \.date) { day in
      // AreaMark to show the range between min and max temperatures
      AreaMark(
        x: .value("Day", day.date, unit: .day),
        yStart: .value("Min Temp", day.minTemperatureCelsius),
        yEnd: .value("Max Temp", day.maxTemperatureCelsius)
      )
      .interpolationMethod(.catmullRom)
      .foregroundStyle(
        LinearGradient(
          gradient: Gradient(colors: [Color.blue.opacity(0.25), Color.orange.opacity(0.2)]),
          startPoint: .bottom,
          endPoint: .top
        )
      )
      
      // Max temperature line
      LineMark(
        x: .value("Day", day.date, unit: .day),
        y: .value("Max Temperature", day.maxTemperatureCelsius)
      )
      .interpolationMethod(.catmullRom)
      .foregroundStyle(by: .value("Series", "Max"))
      .lineStyle(StrokeStyle(lineWidth: 2.5))
      .symbol(Circle().strokeBorder(lineWidth: 2))
      .symbolSize(40)
      .zIndex(1)
      
      // Min temperature line
      LineMark(
        x: .value("Day", day.date, unit: .day),
        y: .value("Min Temperature", day.minTemperatureCelsius)
      )
      .interpolationMethod(.catmullRom)
      .foregroundStyle(by: .value("Series", "Min"))
      .lineStyle(StrokeStyle(lineWidth: 2.5))
      .symbol(Circle().strokeBorder(lineWidth: 2))
      .symbolSize(40)
      .zIndex(1)
    }
  }
  
  /// I have an array of weather data and a target date. I need to find the closest date in the array to the target date.
  /// - Parameters:
  ///   - target:The date as a reference point.
  ///   - weatherData: my weekly weather data array.
  /// - Returns: the weatherdata instance with the closest date to the target date.
  private func findClosestDate(to target: Date?, in weatherData: [WeeklyViewWeather]) -> Date? {
    guard let t = target else { return weatherData.first?.date }
    return weatherData.min(by: {
      abs($0.date.timeIntervalSince(t)) < abs($1.date.timeIntervalSince(t))
    })?.date
  }
  
  
  /// The horizontal scroll view should snap to the closest hour to "now".
  /// - Parameter animated: If true, animate the scroll.
  private func scrollToNow(animated: Bool = true) {
    guard !weeklyWeather.isEmpty else { return }
    let closest = findClosestDate(to: nowMarkerDate, in: weeklyWeather) ?? weeklyWeather.first!.date
    if animated {
      withAnimation { visibleDate = closest }
    } else {
      visibleDate = closest
    }
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        WeeklyInfoHeaderView(weeklyWeather: weeklyWeather)
        
        Chart {
          chartContent
        }
        // Map series names to explicit colors so Max=orange and Min=blue
        .chartForegroundStyleScale([
          "Max": Color.orange,
          "Min": Color.blue
        ])
        .chartXScale(domain: forecastStartDate...forecastEndDate)
        .chartXAxis {
          AxisMarks(values: tickDates()) { value in
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
        .chartYAxisLabel("Min/Max Temperatures", position: .trailing, alignment: .center)
        .chartXAxisLabel("Week (7 Days)", position: .bottom, alignment: .center)
        // Set a fixed height for the chart
        .frame(minHeight: 250)
        .padding()
        
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 12) {
            ForEach(weeklyWeather) { day in
              
              
              VStack(spacing: 5) {
                VStack {
                  Text("\(dateString(from: day.date))")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                  
                  Text(day.locationName)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                  
                  if let region = day.regionName, let country = day.countryName {
                    Text("\(region), \(country)")
                      .font(.headline)
                      .foregroundColor(.white.opacity(0.8))
                  }
                }
                .padding(.top, 10)
                
                HStack {
                  Text(emoji(for: day.weatherDescription.rawValue))
                    .font(.largeTitle)
                  
                  VStack(alignment: .leading, spacing: 8) {
                    VStack {
                      Text("Min: \(day.minTemperatureCelsius, specifier: "%.0f")°")
                      Text("Max: \(day.maxTemperatureCelsius, specifier: "%.0f")°")
                    }
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                  }
                }
                .padding(.bottom, 10)
              }
              .padding([.top,.bottom], 10)
              .padding(.horizontal)
              .frame(minHeight: 100)
              .background(
                LinearGradient(
                  gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
              .cornerRadius(20)
              .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 8)
              .id(day.date)
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea()
          }
          .padding()
          .scrollTargetBehavior(.paging)
        }
        .scrollPosition(id: $visibleDate, anchor: .center)
      }
      
      .onAppear {
        visibleDate = weeklyWeather.first?.date
        scrollToNow(animated: false)
      }
      .onChange(of: nowMarkerDate) {
        scrollToNow()
      }
      .onReceive(timer) { newDate in
        currentDate = newDate
      }
    }
  }
  
  private func dateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, MMM d"
    formatter.timeZone = timeZone
    return formatter.string(from: date)
  }
  
  private func emoji(for code: Int) -> String {
    switch code {
    case 0: return "☀️" // Clear
    case 1, 2: return "🌤️" // Partly cloudy
    case 3: return "☁️" // Cloudy
    case 45, 48: return "🌫️" // Fog
    case 51, 53, 55, 56, 57: return "🌦️" // Drizzle
    case 61, 63, 65, 66, 67: return "🌧️" // Rain
    case 71, 73, 75, 77, 85, 86: return "❄️" // Snow
    case 80, 81, 82: return "🌦️" // Showers
    case 95, 96, 99: return "⛈️" // Thunderstorm
    default: return ""
    }
  }
}


#Preview {
  let mockData = (0..<7).map { i -> WeeklyViewWeather in
    let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
    let minTemp = Float.random(in: 5...10) + Float(i)
    let maxTemp = minTemp + Float.random(in: 5...10)
    return WeeklyViewWeather(
      locationName: "Cupertino",
      regionName: "CA",
      countryName: "USA",
      date: date,
      utcOffsetSeconds: -25200,
      weatherDescription: .partlyCloudy,
      maxTemperatureCelsius: maxTemp,
      minTemperatureCelsius: minTemp
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
    isDay: true
  )
  
  WeeklyWeatherView(weeklyWeather: mockData, currentWeather: mockCurrentWeather)
}
