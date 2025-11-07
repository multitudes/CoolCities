// swift
import Foundation

// Model: holds parsed dates and the timezone used for parsing/formatting
struct TimeSerie {
  let times: [Date]
  let timezone: TimeZone
  let calendar: Calendar
  
  // Parse ISO strings like "2025-11-02T00:00" using provided timezone info.
  // Provide either timezoneIdentifier (preferred) or utcOffsetSeconds.
  init(timeStrings: [String], timezoneIdentifier: String?, utcOffsetSeconds: Int?) throws {
    // decide timezone
    if let id = timezoneIdentifier, let tz = TimeZone(identifier: id) {
      timezone = tz
    } else if let offset = utcOffsetSeconds, let tz = TimeZone(secondsFromGMT: offset) {
      timezone = tz
    } else {
      timezone = .current
    }
    
    // calendar bound to location timezone
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timezone
    calendar = cal
    
    // DateFormatter for the incoming strings (no Z, plain local wall-clock representation in JSON)
    let df = DateFormatter()
    df.calendar = Calendar(identifier: .gregorian)
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd'T'HH:mm"
    df.timeZone = timezone
    
    var parsed: [Date] = []
    for s in timeStrings {
      if let d = df.date(from: s) {
        parsed.append(d)
      } else {
        throw NSError(domain: "TimeSerie", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse \(s)"])
      }
    }
    times = parsed
  }
  
  // Format a Date as a localized time string in the location timezone
  func formattedTime(_ d: Date, format: String = "HH:mm") -> String {
    let f = DateFormatter()
    f.calendar = calendar
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = timezone
    f.dateFormat = format
    return f.string(from: d)
  }
  
  // Generate tick dates for the given day (00:00..23:00) in the location timezone
  // `anchor` selects which day to build (defaults to first parsed date)
  func dayTickDates(stepHours: Int = 1, anchorDay anchor: Date? = nil) -> [Date] {
    guard stepHours > 0 else { return [] }
    let ref = anchor ?? times.first ?? Date()
    // extract year/month/day in the location timezone
    let comps = calendar.dateComponents([.year, .month, .day], from: ref)
    var ticks: [Date] = []
    for hour in stride(from: 0, through: 23, by: stepHours) {
      var c = comps
      c.hour = hour
      c.minute = 0
      c.second = 0
      c.timeZone = timezone
      if let d = calendar.date(from: c) {
        ticks.append(d)
      }
    }
    return ticks
  }
}

// ----- Demonstration -----
// Example small sample (do not repeat large arrays) - these strings are same format as your API.
let sampleTimeStrings = [
  "2025-11-02T00:00",
  "2025-11-02T01:00",
  "2025-11-02T02:00"
]

// Replace with the JSON timezone info you get from the API:
let jsonTimezoneIdentifier: String? = "Europe/Berlin"   // prefer this when available
let jsonUtcOffsetSeconds: Int? = 3600                  // fallback if no identifier

do {
  let ts = try TimeSerie(timeStrings: sampleTimeStrings, timezoneIdentifier: jsonTimezoneIdentifier, utcOffsetSeconds: jsonUtcOffsetSeconds)
  
  print("Timezone used:", ts.timezone.identifier, "secondsFromGMT:", ts.timezone.secondsFromGMT())
  print("Parsed Dates (raw `Date` values):")
  for d in ts.times {
    print("  raw:", d) // prints absolute instant (in UTC form) but represents the local wall-clock parsed earlier
  }
  
  print("\nFormatted in location timezone (should show `00:00`, `01:00`, ...):")
  for d in ts.times {
    print("  ", ts.formattedTime(d))
  }
  
  // Show how the same dates would format in the device locale/timezone (to highlight difference)
  let deviceFormatter = DateFormatter()
  deviceFormatter.locale = .current
  deviceFormatter.dateFormat = "yyyy-MM-dd HH:mm ZZZZ"
  print("\nFormatted in device timezone (may shift if device TZ != location TZ):")
  for d in ts.times {
    print("  ", deviceFormatter.string(from: d))
  }
  
  // Build tick dates for the day (00:00..23:00) in the location timezone
  let ticks = ts.dayTickDates(stepHours: 3) // every 3 hours: 00:00, 03:00, ... 21:00
  print("\nTick dates in location timezone (formatted):")
  for t in ticks {
    print("  ", ts.formattedTime(t))
  }
} catch {
  print("Error creating TimeSerie:", error)
}

// calendar bound to location timezone
var cal = Calendar(identifier: .gregorian)
cal.timeZone = TimeZone(identifier: "Europe/Berlin")!
let calendar = cal

// DateFormatter for the incoming strings (no Z, plain local wall-clock representation in JSON)
let df = DateFormatter()
df.calendar = Calendar(identifier: .gregorian)
df.locale = Locale(identifier: "en_US_POSIX")
df.dateFormat = "yyyy-MM-dd'T'HH:mm"
df.timeZone = cal.timeZone

//
//let now = Date()
//// `calendar` is already configured with the location's timezone.
//let localComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
//
//// 2. Create a new Date object from these components, but interpret them as being in UTC.
//var utcCalendar = Calendar.current
//utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
//
//utcCalendar.date(from: localComponents)
//// Resulting Date now represents the same wall-clock time, but in UTC.
//print("Local components interpreted as UTC date:", utcCalendar.date(from: localComponents)!)


// Recreated helper
func nowMarkerDate(using calendar: Calendar) -> Date? {
  let now = Date()
  // calendar is expected to be configured with the location timezone
  let localComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
  // Build with a UTC calendar -> interpret the *same* wall-clock numbers as UTC
  var utcCalendar = Calendar(identifier: calendar.identifier)
  utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return utcCalendar.date(from: localComponents)
}

// Demonstration
let locationTz = TimeZone(identifier: "Europe/Berlin")! // example location
var locationCalendar = Calendar(identifier: .gregorian)
locationCalendar.timeZone = locationTz

let now = Date()
let marker = nowMarkerDate(using: locationCalendar)!

// Formatters to display results clearly
let isoUTC = DateFormatter()
isoUTC.dateFormat = "yyyy-MM-dd'T'HH:mm:ss ZZZZ"
isoUTC.timeZone = TimeZone(secondsFromGMT: 0)

let isoLocal = DateFormatter()
isoLocal.dateFormat = "yyyy-MM-dd'T'HH:mm:ss ZZZZ"
isoLocal.timeZone = locationTz

print("Now (as absolute Date):       \(isoUTC.string(from: now))  (UTC view)")
print("Now (as location view):       \(isoLocal.string(from: now))  (\(locationTz.identifier) view)")
print("Marker (constructed in UTC):  \(isoUTC.string(from: marker))  (UTC view)")


let secondsDiff = marker.timeIntervalSince(now)
print(String(format: "marker - now = %.0f seconds (%.2f hours)", secondsDiff, secondsDiff / 3600))
