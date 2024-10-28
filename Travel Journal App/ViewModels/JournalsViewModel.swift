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
    
    @Published var allJournals: [JournalSwiftData] = []
    @Published var journals: [JournalSwiftData] = []
    @Published var wasJournalTapped: Bool = false
    @Published var tappedJournal: JournalSwiftData?
    @Published var isNavigateToJournal: Bool = false



    
    // Add custom order array
    @Published var customOrder: [String] = [] // Store journal IDs in custom order
    
    func fetchJournals(journals: [JournalSwiftData]) {
        self.allJournals = journals
        
        // Initialize custom order if empty
        if customOrder.isEmpty {
            customOrder = journals.map { $0.id }
        }
        
        applyFiltersAndSearch()
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        // Update the journals array
        journals.move(fromOffsets: source, toOffset: destination)
        
        // Update the custom order
        if orderState == .custom {
            customOrder = journals.map { $0.id }
            saveCustomOrder()
        }
    }
    
    private func saveCustomOrder() {
        // Save custom order to UserDefaults or your preferred storage
        UserDefaults.standard.set(customOrder, forKey: "journalCustomOrder")
    }
    
    private func loadCustomOrder() {
        if let saved = UserDefaults.standard.array(forKey: "journalCustomOrder") as? [String] {
            customOrder = saved
        }
    }
    
    func applyFiltersAndSearch() {
        var filteredJournals = allJournals
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredJournals = filteredJournals.filter { journal in
                journal.journalTitle.localizedCaseInsensitiveContains(searchText) ||
                journal.placeName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by favourites
        if filterState != .all {
            filteredJournals = filteredJournals.filter { journal in
                journal.isFavourite == true
            }
        }
        
        // Apply ordering
        switch orderState {
        case .title:
            filteredJournals.sort { $0.journalTitle < $1.journalTitle }
        case .date:
            filteredJournals.sort { $0.date > $1.date }
        case .address:
            filteredJournals.sort { $0.address < $1.address }
        case .placeName:
            filteredJournals.sort { $0.placeName < $1.placeName }
        case .custom:
            // Sort based on custom order
            filteredJournals.sort { journal1, journal2 in
                guard let index1 = customOrder.firstIndex(of: journal1.id),
                      let index2 = customOrder.firstIndex(of: journal2.id) else {
                    return false
                }
                return index1 < index2
            }
        }
        
        journals = filteredJournals
    }
}

