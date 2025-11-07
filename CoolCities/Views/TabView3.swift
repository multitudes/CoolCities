// 
//  TabView3.swift
//  CoolCities
//
//  Created by Laurent Brusa on 07/11/2025.
//

import SwiftUI

struct TabView3: View {
  var body: some View {
    NavigationStack {
      
      VStack {
        Text("Chat with CoolCities")
          .font(.largeTitle.bold())
          .padding(.top, 40)
        ScrollView{
          Text(lorem)
            .padding()
          
          
        }
      }
      
      
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      
      .background(Color.appBackground.ignoresSafeArea().opacity(0.6))
      //        .background(Image("weather").resizable().ignoresSafeArea().opacity(0.6))
      
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      
    }
  }
}

#Preview {
  TabView3()
}
