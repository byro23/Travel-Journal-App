//
//  NewPlaceViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation
import MapKit


class NewPlaceViewModel: ObservableObject {
    
    @Published var placeName: String = ""
    @Published var journalEntry: String = ""
    @Published var places: [Place] = []
    @Published var isFetchingSuggestions = false
    
    var placeLongitude: Double = 0.0
    var placeLatitude: Double = 0.0
    
    init(longitude: Double, latitude: Double) {
        placeLongitude = longitude
        placeLatitude = latitude
    }
    
    func fetchNearbyPlaces() {
        isFetchingSuggestions = true
        
        print("Latitude: \(placeLatitude) Longitude: \(placeLongitude)")
        
        let latitudeDelta = 1 / 111.0
        let longitudeDelta = 1 / (111.0 * cos(placeLatitude * .pi / 180))
        
        
        let searchSpan = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        print(searchSpan)
        
        let searchRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: placeLatitude, longitude: placeLongitude), span: searchSpan)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = searchRegion
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.naturalLanguageQuery = "Things to do"
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Search error: \(String(describing: error?.localizedDescription))")
                self.isFetchingSuggestions = false
                return
            }
            
            let fetchedPlaces = response.mapItems.compactMap { mapItem -> Place? in
                guard let name = mapItem.name else { return nil }
                let coordinate = mapItem.placemark.coordinate
                let address = mapItem.placemark.title ?? "No address available"
                
                return Place(placeName: name, placeAddress: address, latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
            
            DispatchQueue.main.async {
                self.places = fetchedPlaces
                self.isFetchingSuggestions = false
            }
        }
        
    }
    
    
}
