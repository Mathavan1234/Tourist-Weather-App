import Foundation
import SwiftUI
import CoreLocation
import MapKit

class WeatherMapViewModel: ObservableObject {
    /* @Published property wrapper is used here to automatically notify and update views when variable value changes */
    
    // represents the current weather data (DTO)
    @Published var weatherDataModel: WeatherDataModel?
    // represents the array of Location objects for tourist places
    @Published var placesDataModel: [Location]?
    // The coordinates (latitude and longtitude) of the current city
    @Published var coordinates: CLLocationCoordinate2D?
    // MKCoordinateRegion that defines the region for the map
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    // Name of the city - Changing this property triggers the loading of weather data & tourist places
    @Published var city: String {
        
        didSet {
                    // Update the coordinates and load data whenever the city changes
                    Task {
                        do {
                            let _ = try await getCoordinatesForCity()
                            loadPlacesData(city: city)
                            
                            _ = try await loadData(lat: coordinates?.latitude ?? 51.503300, lon: coordinates?.longitude ?? -0.079400)
                        } catch {
                            print("Error loading weather data: \(error)")
                        }
                    }
                }
    }

    
    // Class Constructor
    init() {
        
        // Default city is set to "London"
        self.city = "London"
        // passing the London as the parameter city to loadPlacesData function
        loadPlacesData(city: city)
        
        // Load weather data for London only if the user has not entered a city
        if city.isEmpty {
            Task {
                do {
                    // it retreives the coordinates for the specified city
                    let _ = try await getCoordinatesForCity()
                    // loads the data from API using given latitude and longtitude - these default values are for London
                    let _ = try await loadData(lat: coordinates?.latitude ?? 51.503300, lon: coordinates?.longitude ?? -0.079400)
                } catch {
                    print("Error loading weather data: \(error)")
                }
            }
        }
    }
    

    // this function retreives the coordinates for the specified city using CLGeoCoder
    // This method is declared as async as it can be awaited due to geocoding and subsequent updates
    func getCoordinatesForCity() async throws -> CLLocationCoordinate2D {
        
        guard !city.isEmpty else {
            // Handle the case where the city is empty
            print("Error: City is empty.")
            // Replace SomeError with an appropriate error type
            throw SomeError.invalidCoordinates
        }
        
        // Creating the instance of CLGeocoder and attempting to geocode the city using geocodeAddressString
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.geocodeAddressString(city),
           // if it's successfuk it extracts the first set of coordinates from CoreLocationPlcamark
           let location = placemarks.first?.location?.coordinate {

            DispatchQueue.main.async {
                // Updates the coordinates property with the extracted location value
                self.coordinates = location
                // Updates the region property with MKCoordinateRegion based on the obtained coordinates
                self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
            return location
        } else {
            // Handle error here if geocoding fails
            print("Error: Unable to find the coordinates for \(city).")
            // Replace SomeError with an appropriate error type
            throw SomeError.invalidCoordinates
        }
    }

    // this function loads the data from OpenWeatherAPI using a provided latitude and longtitude
    func loadData(lat: Double, lon: Double) async throws -> WeatherDataModel {
        
        // Creating the actual url by URL(url) by passing the url string with the API key
        if let url = URL(string:"https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(APIConstants.KEY)") {
            
            // Creating the URL session to fetch the data
            let session = URLSession(configuration: .default)

            do {
                let (data, _) = try await session.data(from: url)
                // Decoding the data from JSON to Swift by passing DTO - WeatherDataModel
                let weatherDataModel = try JSONDecoder().decode(WeatherDataModel.self, from: data)

                DispatchQueue.main.async {
                    // the obtained weather data model is assigned to weather data model property of instance (UI update)
                    self.weatherDataModel = weatherDataModel
                }

                // Timestamps retrieved as part of API response
                // Minute
                if let count = weatherDataModel.minutely?.count {
                    if let firstTimestamp = weatherDataModel.minutely?[0].dt {
                        let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                        _ = DateFormatterUtils.shared.string(from: firstDate)
                    }

                    if let lastTimestamp = weatherDataModel.minutely?[count - 1].dt {
                        let lastDate = Date(timeIntervalSince1970: TimeInterval(lastTimestamp))
                        _ = DateFormatterUtils.shared.string(from: lastDate)
                    }
                }

                // Hour
                let hourlyCount = weatherDataModel.hourly.count

                if hourlyCount > 0 {
                    let firstTimestamp = weatherDataModel.hourly[0].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    let _ = DateFormatterUtils.shared.string(from: firstDate)
                }

                if hourlyCount > 0 {
                    let lastTimestamp = weatherDataModel.hourly[hourlyCount - 1].dt
                    let lastDate = Date(timeIntervalSince1970: TimeInterval(lastTimestamp))
                    let _ = DateFormatterUtils.shared.string(from: lastDate)
                }

                // Daily
                let dailyCount = weatherDataModel.daily.count

                if dailyCount > 0 {
                    let firstTimestamp = weatherDataModel.daily[0].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    _ = DateFormatterUtils.shared.string(from: firstDate)
                }

                if dailyCount > 0 {
                    let firstTimestamp = weatherDataModel.daily[dailyCount-1].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    _ = DateFormatterUtils.shared.string(from: firstDate)
                }
                return weatherDataModel
            } catch {
                if let decodingError = error as? DecodingError {
                    print("Decoding error: \(decodingError)")
                } else {
                    // Errors during asynchronous operations - data loading and geocoding are caught ans printed
                    print("Error: \(error)")
                }
                // Re-throw the error to the caller
                throw error
            }
        } else {
            throw NetworkError.invalidURL
        }
    }

    // this function loads tourist places data from a JSON file based on the specified city
    func loadPlacesData(city: String) {
        if let fileURL = Bundle.main.url(forResource: "places", withExtension: "json") {
            do {
                // Read the data from the file
                let data = try Data(contentsOf: fileURL)

                // Decode the JSON data into an array of Location objects
                let decoder = JSONDecoder()
                
                // Converting JSON fetched data to swift using Location DTO
                let allLocations = try decoder.decode([Location].self, from: data)

                // Filter locations based on the specified city
                let filteredLocations = allLocations.filter { $0.cityName == city }

                // Update placesDataModel on the main thread
                DispatchQueue.main.async {
                    // the obtained filtered Locations are assigned to places data model property of instance (UI update)
                    self.placesDataModel = filteredLocations
                }
            } catch {
                print("Error loading places data: \(error)")
            }
        } else {
            print("File not found")
        }
    }

    // An enum for Network Error when an invalidURL is encountered
    enum NetworkError: Error {
        case invalidURL
    }
    
    // An enum representing an invalid coordinates error
    enum SomeError: Error {
        case invalidCoordinates
    }
    
}
