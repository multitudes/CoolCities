//
//  ContentView.swift
//
//  Created by Laurent Brusa on 28/10/2025.
//

import SwiftUI
import Combine
import CoreLocation

struct TeamMember: Identifiable {
  let id = UUID()
  let name: String
  let description: String
  let imageName: String
}

let team: [TeamMember] = [
  TeamMember(name: "Stephen", description: "Cognitive scientist and linguist (PhD) with experience in data analysis and computational modeling. Brings systems thinking and user insight to connect data and experience.", imageName: "stephen"),
  TeamMember(name: "Laurent", description: "Software engineer with expertise in Swift, UX, and frontend development. Leads interface design and implementation, turning concepts into intuitive user experiences.", imageName: "laurent"),
  TeamMember(name: "Jen", description: "Business consultant and product manager with cross-cultural experience, harnessing deep insights to turn ideas into strategic impact. ", imageName: "jen"),
  TeamMember(name: "Matthias", description: "Artist and IT aficionado focused on location tracking and spatial data analysis.", imageName: "matthias")
]

let aboutApp1 = """
CoolCities helps tourists and locals plan their days and routes to stay comfortable during hot weather. Using high-resolution satellite data, the app guides users to cooler streets, parks, and green corridors in and around metropolitan areas. Tourists and residents can discover cooler routes, sights and activities, while locals can get to work without breaking a sweat.
"""
let aboutApp2 = """
CoolCities combines data from Copernicus Sentinel 2 and 3 to detect land temperature and vegetation cooling, providing temperature maps at 10 m resolution. Galileo global navigation satellites provide precise positioning for routing through the temperature map. In AR mode, a friendly mascot leads you along your path. CoolCities translates EU space data into user comfort and wellness.
"""

let aboutApp3 = """
EU Space for Consumer Experience (Challenge #3)
We address “Beyond Horizons – Redefining Travel with Space Innovation.”
CoolCities optimizes travel and local exploration by enabling users to plan around heat-island effects, maximizing comfort and well-being during their activities. It helps visitors and citizens navigate safely and comfortably during hot weather and promotes greater climate awareness in travel and tourism.
"""

struct TeamMemberView: View {
  let member: TeamMember
  let isReversed: Bool
  
  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      if isReversed {
        Text(member.description)
          .font(.body)
        VStack {
          Image(member.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .padding()
          Text(member.name)
            .font(.headline)
        }
      } else {
        VStack {
          Image(member.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .padding()
          Text(member.name)
            .font(.headline)
        }
        Text(member.description)
          .font(.body)
      }
    }
    .padding(.vertical)
  }
}


struct ContentView: View {
  @StateObject private var viewModel = WeatherViewModel()
  @StateObject private var locationManager = LocationManager()
  @State private var selectedTab = 1
  
  var body: some View {
    
    TabView(selection: $selectedTab) {
      
      NavigationStack {
        
        VStack {
          Image("CoolCities")
            .resizable()
            .scaledToFit()
            .padding()
            .frame(maxWidth: 200)
          ScrollView{
            Text("CoolCities")
              .font(.largeTitle)
              .padding(.bottom)
            Text("Finding Microclimates in Your City")
              .font(.title2)
            Text(aboutApp1)
              .padding()
            Text("EU Space Technologies")
              .font(.title2)
            Text(aboutApp2)
              .padding()
            Text("Beyond Horizons")
              .font(.title2)
            Text(aboutApp3)
              .padding()
            Text("Team")
              .font(.title2)
              .padding(.top)
            
            ForEach(Array(team.enumerated()), id: \.element.id) { index, member in
              TeamMemberView(member: member, isReversed: index % 2 != 0)
            }
          }
          .padding()
          
        }
        
        .frame(maxWidth: .infinity)
        .background(Color.appBackground.ignoresSafeArea().opacity(0.6))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("About", systemImage: "info.circle")
      }
      .tag(1)
      
      
      NavigationStack {
        VStack(spacing: 0) {
          CustomSearchHeader(searchText: $viewModel.searchText, onGeoLocationTap: viewModel.onGeoLocationTap)
            .onChange(of: viewModel.searchText) { _, newValue in
              if !newValue.isEmpty {
                viewModel.performSearch(for: newValue)
              }
            }
          VStack {
            if viewModel.state == .isGeolocationRequested {
              GeolocationStatusView(locationManager: locationManager, weatherViewModel: viewModel)
              
            } else {
              VStack {
                if viewModel.state == .isLoading {
                  ProgressView()
                    .padding()
                } else if case let .error(message) = viewModel.state{
                  Text(message)
                    .foregroundColor(.red)
                    .padding()
                } else if viewModel.state == .locationSelected {
                  if let todaysWeather = viewModel.todaysWeather {
                    TodaysLocationView(todaysWeather: todaysWeather, currentWeather: viewModel.currentWeather)
                      .environmentObject(viewModel)
                  } else {
                    Text("No location selected")
                      .foregroundColor(.gray)
                      .padding()
                  }
                }
                else if viewModel.locations.isEmpty && !viewModel.searchText.isEmpty && viewModel.state != .isLoading {
                  Text("No matches for '\(viewModel.searchText)'")
                    .foregroundColor(.gray)
                    .padding()
                } else {
                  LocationListView(locations: viewModel.locations, selectLocation: viewModel.selectLocation)
                }
              }
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          
        }
        .background(Color.appBackground.ignoresSafeArea().opacity(0.8))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("Today", systemImage: "calendar.day.timeline.leading")
      }
      .tag(2)
      
      TabView3()
      
        .tabItem {
          Label("Chat", systemImage: "bubble.left.circle")
        }
        .tag(3)
    }
    .onAppear {
      locationManager.requestLocationAuthorization()
    }
    .onChange(of: selectedTab) {
      viewModel.reset()
    }
//    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//      .onEnded({ value in
//        if value.translation.width < 0 {
//          print("Left Swipe")
//          selectedTab = min(selectedTab + 1, 3)
//        }
//        if value.translation.width > 0 {
//          print("Right Swipe")
//          selectedTab = max(selectedTab - 1, 1)
//        }
//        viewModel.reset()
//      }))
  }
}


#Preview {
  ContentView()
}
