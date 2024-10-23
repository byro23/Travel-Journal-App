//
//  Place.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation


class Place {
    
    let id = UUID().uuidString
    let placeName: String
    let address: String
    let latitude: Double
    let longitude: Double
    let userId = UUID().uuidString
    
    init(placeName: String, address: String, latitude: Double, longitude: Double) {
        self.placeName = placeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
