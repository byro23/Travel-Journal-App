//
//  JournalDetailedViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 28/10/2024.
//

import Foundation

class JournalDetailedViewModel: ObservableObject {
    
    @Published var isFavourite: Bool = false
    
    
    func setFavouriteIcon(isFavourite: Bool) {
        self.isFavourite = isFavourite
    }
    
}
