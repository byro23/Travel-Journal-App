//
//  JournalSwiftData.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import Foundation
import SwiftData

@Model
class JournalSwiftData: Identifiable {
    
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
    
    init(id: String = UUID().uuidString, journalTitle: String, journalEntry: String, date: Date, placeName: String, address: String, latitude: Double, longitude: Double, userId: String, imageReferences: [String]) {
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

extension JournalSwiftData {
    static let MOCK_JOURNAL: JournalSwiftData = JournalSwiftData(journalTitle: "Coastal Drive", journalEntry: "This is a test journal entry", date: Date(), placeName: "Bondi Beach", address: "Bondi Beach, NSW", latitude: 0, longitude: 0, userId: "", imageReferences: [""])
}
