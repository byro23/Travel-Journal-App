//
//  PlaceListView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 25/10/2024.
//

import SwiftUI

struct PlaceListView: View {
    
    @Binding var showSheet: Bool
    @Binding var placeName: String
    @Binding var placeAddress: String
    let places: [Place]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundStyle(.yellow)
                        Text("Tap a suggestion to autofill the form.")
                    }
                    ForEach(places) { place in
                        PlaceRow(place: place)
                            .onTapGesture {
                                handleSuggestionTap(placeName: place.placeName, placeAddress: place.placeAddress)
                            }
                    }
                    
                }
                
            }
            .navigationTitle("Nearby places")
        }
        
    }
    
    private func handleSuggestionTap(placeName: String, placeAddress: String) {
        self.placeName = placeName
        self.placeAddress = placeAddress
        self.showSheet = false
    }
}

struct PlaceListView_Previews: PreviewProvider {
    static var previews: some View {
        var places: [Place] = [] // Use `var` to allow appending elements
        places.append(Place.MOCK_PLACE) // Assuming `MOCK_PLACE` is a static constant
        return PlaceListView(showSheet: .constant(false), placeName: .constant(""), placeAddress: .constant(""), places: places)
    }
}

