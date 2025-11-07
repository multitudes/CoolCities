// 
//  CustomSearchHeader.swift
//  MediumWeather02
//
//  Created by Laurent Brusa on 31/10/2025.
//

import SwiftUI


struct CustomSearchHeader: View {
  @Binding var searchText: String
  var onGeoLocationTap: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.primary).opacity(0.5)
      
      
      TextField("Search location...", text: $searchText)
        .foregroundColor(.primary)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
      
      Button {
        onGeoLocationTap()
      } label: {
        Image(systemName: "location.fill")
          .font(.title2)
          .foregroundColor(.blue)
      }
    }
    .padding(12)
    .background(Color(.tertiarySystemBackground).opacity(0.7))
    .cornerRadius(12)
    .padding([.horizontal, .top], 16)
  }
}


#Preview {
    CustomSearchHeader(searchText: .constant(""), onGeoLocationTap: {})
}
