//
//  WeatherNowView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import SwiftUI

struct WeatherNowView: View {
    /* Since weatherMapViewModel object is an observed object shared among multiple views, it's declared with the
     property wrapper @@EnvironmentObject */
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    // A boolean state property which indicates whether the view is currently loading
    @State private var isLoading = false
    // A string state property to temporarily store the user-entered city for changing the location
    @State private var temporaryCity = ""
    
    var body: some View {
        // View is wrapped in Navigation View
        NavigationView{
            // Used to put the background image - since elements are stacked top on each ZStack is used
            ZStack{
                Image("sky")
                    .resizable()
                    // image fills the available space
                    .scaledToFill()
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                    .opacity(0.75)
                
                VStack{
                    HStack{
                        Text("Change Location")
                        
                        // For users to enter a new location
                        TextField("Enter New Location", text: $temporaryCity)
                        /* this onSubmit closure updates the city in the WeatherMapViewModel and triggers the
                        asynchronous task to get coordinates for the new city */
                            .onSubmit {
                                weatherMapViewModel.city = temporaryCity
                                Task {
                                    do {
                                        // to process user change of location
                                        weatherMapViewModel.city = temporaryCity
                                        _ = try await weatherMapViewModel.getCoordinatesForCity()
                                    } catch {
                                        print("Error: \(error)")
                                        isLoading = false
                                    }
                                }
                            }
                            .onAppear {
                                // Set initial values to London when the view appears
                                Task {
                                    do {
                                        if(temporaryCity.isEmpty){
                                            weatherMapViewModel.city = "London"
                                            _ = try await weatherMapViewModel.getCoordinatesForCity()
                                        }
                                        
                                    } catch {
                                        print("Error: \(error)")
                                        isLoading = false
                                    }
                                }
                            }
                    }
                    .bold()
                    .font(.system(size: 20))
                    .padding(10)
                    .shadow(color: .blue, radius: 10)
                    .cornerRadius(10)
                    .fixedSize()
                    .font(.custom("Arial", size: 26))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(15)
                    
                    
                    VStack{
                        HStack{
                            // text to display the current location
                            Text("Current Location: \(weatherMapViewModel.city)")
                        }
                        .bold()
                        .font(.system(size: 20))
                        .padding(10)
                        .shadow(color: .blue, radius: 10)
                        .cornerRadius(10)
                        .fixedSize()
                        .font(.custom("Arial", size: 26))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(15)
                        
                        let timestamp = TimeInterval(weatherMapViewModel.weatherDataModel?.current.dt ?? 0)
                        // the current date and time formatted using DateFormatterUtils.formattedDateTime
                        let formattedDate = DateFormatterUtils.formattedDateTime(from: timestamp)
                        // text to display the formatted current date and time
                        Text(formattedDate)
                            .padding()
                            .font(.title)
                            .foregroundColor(.black)
                            .shadow(color: .black, radius: 1)

                        HStack{
                            // used to access weather details
                            if let forecast = weatherMapViewModel.weatherDataModel {
                                // Hstack to display weather details
                                HStack{
                                    VStack{
                                        // displays current weather icon
                                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(forecast.current.weather[0].icon)@2x.png")) { image in
                                                image
                                                .resizable()
                                                .scaledToFill()
                                            } placeholder: {}
                                            .frame(width: 80, height: 80)
                                        
                                        // displays temperature icon
                                        Image("temperature").resizable().frame(width: 40, height: 40).padding(.bottom,10)
                                        // displays humidity icon
                                        Image("humidity").resizable().frame(width: 40, height: 40).padding(.bottom,10)
                                        // displays pressure icon
                                        Image("pressure").resizable().frame(width: 40, height: 40).padding(.bottom,10)
                                        // displays windspeed icon
                                        Image("windSpeed").resizable().frame(width: 40, height: 40).padding(.bottom,10)
                                    }
                                    
                                    VStack{
                                        // text which displays weather description
                                        Text("\(forecast.current.weather[0].weatherDescription.rawValue.capitalized)")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .shadow(color: .black, radius: 0.5).padding()
                                        
                                        // text which displays temperature
                                        Text("Temp: \((Double)(forecast.current.temp), specifier: "%.2f") ºC")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .shadow(color: .black, radius: 0.5).padding()
                                        
                                        // text which displays humidity
                                        Text("Humidity: \((Double)(forecast.current.humidity), specifier: "%.0f") %")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .shadow(color: .black, radius: 0.5).padding()
                                        
                                        // text which displays pressure
                                        Text("Pressure: \((Double)(forecast.current.pressure), specifier: "%.0f") hPa")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .shadow(color: .black, radius: 0.5).padding()
                                        
                                        // text which displays windspeed
                                        Text("Windspeed: \((Double)(forecast.current.windSpeed), specifier: "%.0f") mph")
                                            .font(.title3)
                                            .foregroundColor(.black)
                                            .shadow(color: .black, radius: 0.5).padding()
                                    }
                                    
                                }
                                .padding(.top,50)
                                .padding(.leading,15)
                                .padding(.trailing,15)
                            } else {
                                Text("Temp: N/A")
                                    .font(.system(size: 25, weight: .medium))
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct WeatherNowView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherNowView().environmentObject(WeatherMapViewModel())
    }
}
