//
//  Place.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation

class Journal: Identifiable, Encodable, Decodable {
    
    var id = UUID().uuidString
    var journalTitle: String
    var journalEntry: String
    var date: Date
    var placeName: String
    var address: String
    var latitude: Double
    var longitude: Double
    var userId: String
    var imageReferences: [String]
    var isFavourite: Bool
    
    init(id: String = UUID().uuidString, journalTitle: String, journalEntry: String, date: Date, placeName: String, address: String, latitude: Double, longitude: Double, userId: String, imageReferences: [String], isFavourite: Bool) {
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
        self.isFavourite = isFavourite
    }
}


