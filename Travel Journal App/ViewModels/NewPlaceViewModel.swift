//
//  NewPlaceViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation


class NewPlaceViewModel: ObservableObject {
    
    @Published var placeName: String = ""
    @Published var journalEntry: String = ""
}
