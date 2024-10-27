//
//  JournalsViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import Foundation
import SwiftData


enum FilterState {
    case date
    case favourites
}


class JournalsViewModel: ObservableObject {
    
    @Published var filterState: FilterState = .date
    @Published var searchText: String = ""
    
    @Published var journals: [JournalSwiftData] = []
    @Published var wasJournalTapped: Bool = false
    @Published var tappedJournal: JournalSwiftData?
    
    
    func fetchJournals(journals: [JournalSwiftData]) {
        self.journals = journals
    }
}
