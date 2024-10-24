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
