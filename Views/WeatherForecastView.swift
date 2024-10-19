//
//  WeatherForcastView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import SwiftUI

struct WeatherForecastView: View {
    /* Since weatherMapViewModel object is an observed object shared among multiple views, it's declared with the
     property wrapper @@EnvironmentObject */
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    
    var body: some View {
        // View is wrapped in Navigation View
        NavigationView {
            ScrollView{
                // Used ZStack to add the background image
                ZStack{
                    Image("appBackground")
                        .resizable()
                        // fills the available space of the screen
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if let hourlyData = weatherMapViewModel.weatherDataModel?.hourly {
                            // horizontal scrollview for displaying hourly weather information
                            /* disabled the scroll indicator bar (little bar that appears to show more content) by setting it to false */
                            ScrollView(.horizontal, showsIndicators: false) {

                                HStack(spacing: 10) {

                                    ForEach(hourlyData) { hour in
                                        // Calling the HourWeatherView where each hour is represented
                                        HourWeatherView(current: hour)
                                    }
                                }
                                // adds padding of 5 horizontal to the scroll view
                                .padding(.horizontal, 5)
                            }
                            // adds padding to top, bottom and leading of scroll view
                            .padding(.bottom,30)
                            .padding(.top,20)
                            .padding(.leading,10)
                            .frame(height:250)
                        }
                            // List which displays daily weather information
                            List {
                                ForEach(weatherMapViewModel.weatherDataModel?.daily ?? []) { day in
                                    // Calling the DailyWeatherView where each day is represented
                                    DailyWeatherView(day: day)
                                }
                            }
                            // setting the background of list to transulent material (.ultraThinMaterial)
                            .background(.ultraThinMaterial)
                            // list opacity is reduced, creating a semi-transparent effect
                            .opacity(0.85)
                            // given the list style of GroupedListStyle - sections and cells arranged in group
                            .listStyle(GroupedListStyle())
                    }
                }
            }
            // navigation bar title to appear inline with the view (includes an icon and the city name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                        // Toolbar item placement is principal/main position of the toolbar - centered icon & name
                        ToolbarItem(placement: .principal) {
                            HStack {
                                Image(systemName: "sun.min.fill")
                                VStack {
                                    Text("Weather Forecast for \(weatherMapViewModel.city)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                            }
                            // Padding of 10 from the top to the content inside ToolbarItem
                            .padding(.top,10)
                        }
                    }
             }
       }
}

struct WeatherForcastView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherForecastView().environmentObject(WeatherMapViewModel())
    }
}
