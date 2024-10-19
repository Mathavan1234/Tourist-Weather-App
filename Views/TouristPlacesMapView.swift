//
//  TouristPlacesMapView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

struct TouristPlacesMapView: View {
    /* Since weatherMapViewModel object is an observed object shared among multiple views, it's declared with the
     property wrapper @@EnvironmentObject */
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    
    // state property locations - an array of location objects representing tourist places
    @State var locations: [Location] = []
    /* state property mapRegion - represents the region to display on the map.It initialized with default coordinates (latitude,longtitude and meters for the span) */
    @State var  mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5216871, longitude: -0.1391574), latitudinalMeters: 4500, longitudinalMeters: 4500)
    
    var body: some View {
        // View is wrapped in Navigation View
        NavigationView {

                VStack{
                    /*
                     Map is created with following properties
                     coordinateRegion - Bound to mapRegion state variable, gives center and span of the displayed region
                     showsUserLocation - Set to True to display user's location on the map
                     annotationTerms - Uses weatherMapViewModel.placesDataModel to populate annotations on the map
                     annotationContent - Defines the content of each annotation using custom MapAnnotationView
                     */
                    Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: weatherMapViewModel.placesDataModel ?? [], annotationContent: {location in MapAnnotation(coordinate: location.coordinates){
                        // Custom Annotation View - LocationMapAnnotationView used as annotation content view
                        LocationMapAnnotationView()
                    }})
                    .ignoresSafeArea()
                
                    // Text which displays the city's tourist attractions
                    Text("Tourist Attractions in  \(weatherMapViewModel.city)")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    // To display tourist places as a list of places
                    List {
                        // For each location in weatherMapViewModel.placesDataModel it loops
                        ForEach(weatherMapViewModel.placesDataModel ?? []) { location in
                            HStack{
                                // Image of the location
                                Image(location.imageNames[0])
                                    .resizable()
                                    .cornerRadius(10)
                                    .ignoresSafeArea()
                                    .frame(width: 120, height: 120)
                                    .padding(.trailing,20)
                                
                                VStack (alignment: .leading){
                                    // Text which displays the name of location
                                    Text("\(location.name)")
                                        .font(.title3)
                                        .padding(.bottom,10)
                                        .foregroundColor(.black)
                                        .bold()
                                    
                                    // Text which displays the description of location
                                    Text("Description: \(location.description)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .frame(height:700)
                .padding()
        }
        /* The onAppear modifier is used to perform actions when the view appears. In this case, it triggers an asynchronous task to get coordinates for the city using the getCoordinatesForCity method from the WeatherMapViewModel */
        .onAppear {

            Task.init {
                do {
                    let coordinates = try await weatherMapViewModel.getCoordinatesForCity()
                    mapRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 4500, longitudinalMeters: 4500)
                } catch {
                    print("Error getting coordinates for city: \(error)")
                }
            }
        }
    }
}


struct TouristPlacesMapView_Previews: PreviewProvider {
    static var locations = WeatherMapViewModel().placesDataModel
    static var previews: some View {
        TouristPlacesMapView().environmentObject(WeatherMapViewModel())
    }
}
