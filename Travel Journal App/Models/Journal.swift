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
    var journalTitle: String
    var journalEntry: String
    var date: Date
    var placeName: String
    var address: String
    var latitude: Double
    var longitude: Double
    var userId = UUID().uuidString
    var imageReferences: [String]
    
    init(id: String = UUID().uuidString, journalTitle: String, journalEntry: String, date: Date, placeName: String, address: String, latitude: Double, longitude: Double, userId: String = UUID().uuidString, imageReferences: [String]) {
        self.id = id
        self.journalTitle = journalTitle
        self.journalEntry = journalEntry
        self.date = date
        self.placeName = placeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.userId = userId
        self.imageReferences = imageReferences
    }
}
