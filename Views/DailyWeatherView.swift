//
//  DailyWeatherView.swift
//  CWK2Template
//
//  Created by girish lukka on 02/11/2023.
//

import SwiftUI

struct DailyWeatherView: View {
    // represents the weather information for a specific day
    var day: Daily
    
    var body: some View {
            HStack{
                /* AsyncImage to load and display image from URL constructed using the weather icon code from the OpenWeatherMap API */
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(day.weather[0].icon)@2x.png")) { image in image
                       .resizable()
                       .scaledToFill()
                // placeholder is provided (currently empty) - used to check status of the fetched image
                } placeholder: {}
                .frame(width: 50, height: 50)
                
                Spacer()
                
                VStack {
                    /* formats the date with a weekday and day using utility method (DateFormatterUtils.formattedDateWithWeekdayAndDay) eg:- Thursday 07 */
                    let formattedDate = DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(day.dt))
                    // Text which displays formatted date
                    Text(formattedDate)
                    .font(.body)
                    
                    // Text which displays capitalized description of the weather eg:- Moderate Rain
                    Text("\(day.weather[0].weatherDescription.rawValue.capitalized)")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                }
                
                Spacer()
                
                // Text element which displays maximum and minimum temperature of the day - extracted from the day model and formatted to strings by adding ºC symbol eg :- 8ºC/5ºC
                Text("\((Int)(day.temp.max))ºC/\((Int)(day.temp.min))ºC")
                    .font(.body)
                    .padding()
            }
    }
}

struct DailyWeatherView_Previews: PreviewProvider {
    static var day = WeatherMapViewModel().weatherDataModel!.daily
    static var previews: some View {
        DailyWeatherView(day: day[0])
    }
}


