//
//  NewPlaceViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation
import GooglePlaces


class NewPlaceViewModel: ObservableObject {
    
    @Published var placeName: String = ""
    @Published var journalEntry: String = ""
    
    var placeLongitude: Double = 0.0
    var placeLatitude: Double = 0.0
    
    @Published var placeResults: [GMSPlace] = []
    
    init(longitude: Double, latitude: Double) {
        placeLongitude = longitude
        placeLatitude = latitude
    }
    
    func fetchNearByPlaces() {
        
        // Define the search area as a 3000 meter diameter circle in San Francisco, CA.
        let circularLocationRestriction = GMSPlaceCircularLocationOption(CLLocationCoordinate2DMake(placeLatitude, placeLatitude), 3000) // Look for nearby places in a 3km radius
        
        // Specify the fields to return in the GMSPlace object for each place in the response.
        let placeProperties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.formattedAddress].map {$0.rawValue}
        
        // Create the GMSPlaceSearchNearbyRequest, specifying the search area and GMSPlace fields to return.
        var request = GMSPlaceSearchNearbyRequest(locationRestriction: circularLocationRestriction, placeProperties: placeProperties)
        let includedTypes = ["restaurant", "cafe", "tourist_attraction", "museum", "art_gallery", "zoo", "amusement_park",
        "lodging", "campground", "restaurant", "cafe", "bakery", "bar"]
        
        request.includedTypes = includedTypes

        let callback: GMSPlaceSearchNearbyResultCallback = { [weak self] results, error in
          guard let self, error == nil else {
            if let error {
              print(error.localizedDescription)
            }
            return
          }
          guard let results = results as? [GMSPlace] else {
            return
          }
          placeResults = results
        }

        GMSPlacesClient.shared().searchNearby(with: request, callback: callback)
    }
    
}
