//
//  Place.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation
import SwiftData

@Model
class Journal: Identifiable {
    
    var id = UUID().uuidString
    var placeName: String
    var address: String
    var latitude: Double
    var longitude: Double
    var journalEntry: String
    var userId = UUID().uuidString
    
    init(id: String = UUID().uuidString, placeName: String, address: String, latitude: Double, longitude: Double, journalEntry: String, userId: String = UUID().uuidString) {
        self.id = id
        self.placeName = placeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.journalEntry = journalEntry
        self.userId = userId
    }
}
