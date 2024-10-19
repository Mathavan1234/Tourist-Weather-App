//
//  NavBar.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import SwiftUI

struct NavBar: View {
    var body: some View {
        // To display tabView for each view in the application
        TabView {
            // it is associated with WeatherNowView view.
            WeatherNowView()
                .tabItem {
                    // labelled with City and has a magnifyingglass icon
                    Label("City", systemImage: "magnifyingglass")
                }
            // it is associated with WeatherForecastView view.
            WeatherForecastView()
                .tabItem {
                    // labelled with Forecast and has a calendar icon
                    Label("Forecast", systemImage: "calendar")
                }
            // it is associated with TouristPlacesMapView view.
            TouristPlacesMapView()
                .tabItem {
                    // labelled with Place Map and has a map icon
                    Label("Place Map", systemImage: "map")
                }
            
        }
        // background color of Tabview is set to white
        .background(Color.white)
    }
}

// This struct initializes an instance of NavBar to preview
struct NavBar_Previews: PreviewProvider {
    static var previews: some View {
        NavBar().environmentObject(WeatherMapViewModel())
    }
}
