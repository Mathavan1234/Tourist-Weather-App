//
//  HourWeatherView.swift
//  CWK2Template
//
//  Created by girish lukka on 02/11/2023.
//

import SwiftUI

struct HourWeatherView: View {
    /* Since weatherMapViewModel object is an observed object shared among multiple views, it's declared with the
     property wrapper @@EnvironmentObject */
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    // represents the current weather information for a specific hour
    var current: Current

    var body: some View {
        /* formats the date with a day using utility method (DateFormatterUtils.formattedDateWithDay)
           eg:- 2 PM Thu */
        let formattedDate = DateFormatterUtils.formattedDateWithDay(from: TimeInterval(current.dt))
        // Used ZStack to add the rectangle shape to display hour weather details
        ZStack {
                            
            Rectangle()
            // added teal - blue colour to the rectangle
            .fill(Color.teal)
                                
            VStack(alignment: .center) {
                // Text Displays the formatted date
                Text(formattedDate)
                    // sets the font size and style to default body style
                    .font(.body)
                    // adds horizontal padding to the text
                    .padding(.horizontal)
                    // sets the text color to black
                    .foregroundColor(.black)
                
                /* AsyncImage to load and display image from URL constructed using the weather icon code from the OpenWeatherMap API */
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(current.weather[0].icon)@2x.png")) { image in
                    image
                    .resizable()
                    .scaledToFill()
                  // placeholder is provided (currently empty) - used to check status of the fetched image
                } placeholder: {}
                .frame(width: 50, height: 50)
                
                
                // Text diplaying capitalized description of the weather eg :- Light Rain
                Text("\(current.weather[0].weatherDescription.rawValue.capitalized)").font(.system(size: 15))
                    .foregroundColor(.black)
            }
            // adds padding to the left and right side of the VStack
            .padding(.trailing,20)
            .padding(.leading,20)
        }
        // Given a fixed frame size of width 150 and height 200 for ZStack
        .frame(width:150, height: 200)
        // clip the view of ZStack with Rounded rectangle shape with corner radius of 15
        .clipShape(RoundedRectangle(cornerRadius: 15))
        // Padding of 30 from top of the ZStack
        .padding(.top,30)
    }
}




