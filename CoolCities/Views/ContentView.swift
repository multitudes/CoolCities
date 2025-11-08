//
//  ContentView.swift
//
//  Created by Laurent Brusa on 28/10/2025.
//

import SwiftUI
import Combine
import CoreLocation

let lorem = """
💎 Idea
CoolCities ❄️ helps tourists and locals plan their days and routes to stay comfortable during hot weather. Using high-resolution satellite data, the app guides users to cooler streets, parks, and green corridors in and around metropolitan areas. Tourists and residents can discover cooler routes, sights and activities, while locals can get to work without breaking a sweat.

🛰️ EU space technologies
CoolCities combines data from Copernicus Sentinel 2 and 3 to detect land temperature and vegetation cooling, providing temperature maps at 10 m resolution. Galileo global navigation satellites provide precise positioning for routing through the temperature map. In AR mode, a friendly mascot leads you along your path. CoolCities translates EU space data into user comfort and wellness.

🚀 EU Space for Consumer Experience (Challenge #3)
We address “Beyond Horizons – Redefining Travel with Space Innovation.”
CoolCities optimizes travel and local exploration by enabling users to plan around heat-island effects, maximizing comfort and well-being during their activities. It helps visitors and citizens navigate safely and comfortably during hot weather and promotes greater climate awareness in travel and tourism.


🤼 Team

Stephen – Cognitive scientist and linguist (PhD) with experience in data analysis and computational modeling. Brings systems thinking and user insight to connect data and experience.
Laurent – iOS engineer with expertise in Swift, UX, and frontend development. Leads interface design and implementation, turning concepts into intuitive user experiences.
Jen - User experience expert, her role is to manage and analyze all customer and potential customer interactions and data
Matthias – Data scientist specializing in analysis and modeling. Handles data processing and fusion of Sentinel and Galileo datasets into usable temperature and navigation layers.

"""

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
            Text(lorem)
              .padding()
            
            
          }
          
        }

        .frame(maxWidth: .infinity)
        .background(Color.appBackground.ignoresSafeArea().opacity(0.6))
        //        .background(Image("weather").resizable().ignoresSafeArea().opacity(0.6))
        
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("About", systemImage: "info.circle")
      }
      .tag(1)
      
      
      // --- 2. Today Tab ---
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
        //        .background(Image("weather").resizable().ignoresSafeArea().opacity(0.6))
        
        
        //        .ignoresSafeArea(edges: .top)
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
      .tag(1)
    }
    
    
    .onAppear {
      locationManager.requestLocationAuthorization()
    }
    .onChange(of: selectedTab) {
      viewModel.reset()
    }
    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
      .onEnded({ value in
        if value.translation.width < 0 {
          print("Left Swipe")
          selectedTab = min(selectedTab + 1, 3)
        }
        if value.translation.width > 0 {
          print("Right Swipe")
          selectedTab = max(selectedTab - 1, 1)
        }
        viewModel.reset()
      }))
  }
}


#Preview {
  ContentView()
}
