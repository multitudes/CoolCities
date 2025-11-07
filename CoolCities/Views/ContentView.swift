//
//  ContentView.swift
//
//  Created by Laurent Brusa on 28/10/2025.
//

import SwiftUI
import Combine
import CoreLocation

let lorem = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ornare imperdiet justo quis fringilla. Fusce molestie porttitor quam ut auctor. Etiam feugiat ligula at tortor fermentum, vel egestas lacus vulputate. Morbi ornare sagittis enim ut porttitor. Aliquam nec nibh eget elit lobortis hendrerit non at mi. Phasellus et felis ut tellus molestie fermentum. Nunc blandit sem ac ante porta tincidunt. Nunc nec risus at mi pulvinar dapibus. Proin interdum magna diam. Nullam nec eleifend dolor, rutrum volutpat neque. Vestibulum iaculis, leo sit amet varius consectetur, ante nibh rhoncus urna, vel porttitor nulla odio eleifend diam. Pellentesque nec vestibulum sapien. Ut vitae nisl tincidunt, vulputate risus ut, elementum massa.

Nunc egestas porta interdum. Maecenas tristique eros ut enim sollicitudin aliquet. Sed auctor metus sed ornare congue. Fusce at tellus neque. Phasellus viverra ante urna, a maximus dui consectetur id. Nullam eu lacus ut nulla efficitur iaculis a quis diam. Sed ut vestibulum nisi, non tempor ante. In eget semper erat, sed laoreet neque.

Mauris fringilla eleifend libero ac blandit. Donec vehicula nunc sed viverra volutpat. Nunc tincidunt volutpat scelerisque. Etiam tortor dui, pulvinar sit amet suscipit in, blandit a tellus. Curabitur est felis, tincidunt sed urna quis, porttitor eleifend nulla. Praesent blandit lacinia posuere. Sed sollicitudin, lorem at hendrerit cursus, erat velit pulvinar tortor, sed mattis sapien tortor vel urna. Pellentesque vel fringilla tortor. Aenean eu libero tempor, elementum purus id, ultrices leo. Ut nec auctor diam, ac scelerisque sapien. Aliquam erat volutpat. Pellentesque at elit vitae erat semper auctor. Ut felis lacus, consectetur in ornare at, consequat vel mi. Donec ante est, laoreet vitae metus nec, interdum consectetur leo.

"""

struct ContentView: View {
  @StateObject private var viewModel = WeatherViewModel()
  @StateObject private var locationManager = LocationManager()
  @State private var selectedTab = 2
  
  var body: some View {
    
    TabView(selection: $selectedTab) {
      
      NavigationStack {
        ScrollView(.vertical, showsIndicators: false) {
          
          VStack {
            Text("CoolCities")
              .font(.largeTitle.bold())
              .padding(.top, 40)
            
            Text(lorem)
              .padding()
            
          }
          
          
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBackground.ignoresSafeArea().opacity(0.2))
        .background(Image("weather").resizable().ignoresSafeArea().opacity(0.6))
        
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("About", systemImage: "info.circle")
      }
      .tag(1)
      
      
      // --- 2. Today Tab ---
      NavigationStack {
        VStack(alignment: .center){
        ScrollView(.vertical, showsIndicators: false) {
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
        .background(Color.appBackground.ignoresSafeArea().opacity(0.2))
        .background(Image("weather").resizable().ignoresSafeArea().opacity(0.6))
      
        }
//        .ignoresSafeArea(edges: .top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        Label("Today", systemImage: "calendar.day.timeline.leading")
      }
      .tag(2)
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
