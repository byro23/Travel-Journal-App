//
//  JournalsViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import Foundation
import SwiftData
import FirebaseFirestore

enum FilterState {
    case all
    case favourites
}

enum OrderState {
    case title
    case placeName
    case address
    case date
    case custom
    
}

class JournalsViewModel: ObservableObject {
    
    @Published var filterState: FilterState = .all
    @Published var orderState: OrderState = .date
    @Published var searchText: String = ""
    
    @Published var allJournals: [JournalSwiftData] = [] // Store all journals initially
    @Published var journals: [JournalSwiftData] = [] // Filtered journals to display
    @Published var wasJournalTapped: Bool = false
    @Published var tappedJournal: JournalSwiftData?
    
    @Published var isNavigateToJournal: Bool = false
    
    @Published var firebaseJournals : [Journal] = []
    
    
    // fetch Journals from firebase
    func fetchJournalsFromFirebase(for userId: String, completion: (() -> Void)? = nil) {
        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("journals")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching journals: \(String(describing: error))")
                    return
                }

                self.firebaseJournals = documents.compactMap { doc -> Journal? in
                    try? doc.data(as: Journal.self)
                }

                // Print inside the completion handler to ensure firebaseJournals is populated
                print("Fetched journals: \(self.firebaseJournals.count) entries")
                print("first journal is \(self.firebaseJournals.first?.journalTitle ?? "")")

                // Call the completion handler if provided
                completion?()
            }
    }

    
    // Fetch and assign journals from the map view
    func fetchJournals(journals: [JournalSwiftData]) {
        self.allJournals = journals
        applyFiltersAndSearch()
    }
    
    // Apply filtering and searching logic
    func applyFiltersAndSearch() {
        var filteredJournals = allJournals
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredJournals = filteredJournals.filter { journal in
                journal.journalTitle.localizedCaseInsensitiveContains(searchText) ||
                journal.placeName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filter state (favorites or date)
        switch orderState {
        case .title:
            filteredJournals.sort { $0.journalTitle < $1.journalTitle}
        case .date:
            filteredJournals.sort { $0.date > $1.date }
        case .address:
            filteredJournals.sort {$0.address < $1.address}
        case .placeName:
            filteredJournals.sort {$0.placeName < $1.placeName}
        case .custom:
            break
        }
        
        // Update the published journals array
        journals = filteredJournals
    }
    
    // Update the filter state and apply filters
    func updateFilter(to newFilter: FilterState) {
        filterState = newFilter
        applyFiltersAndSearch()
    }
}

