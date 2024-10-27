//
//  Place.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation

struct Place: Identifiable {
    let id = UUID()
    let placeName: String
    let placeAddress: String
    let latitude: Double
    let longitude: Double
}

extension Place {
    static let MOCK_PLACE = Place(placeName: "Opera House", placeAddress: "Bennelong Point, Sydney NSW 2000"
, latitude: 33.8568, longitude: 151.2153)
}
