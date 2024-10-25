//
//  NewPlaceSheet.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import SwiftUI

struct NewPlaceView: View {
    
    @StateObject var viewModel: NewPlaceViewModel
    @Binding var showingSheet: Bool
    @Environment(\.modelContext) private var context // For using Swift Data
    
    init(showingSheet: Binding<Bool>, longitude: Double, latitude: Double) {
        self._showingSheet = showingSheet // Assign the binding variable
        _viewModel = StateObject(wrappedValue: NewPlaceViewModel(longitude: longitude, latitude: latitude)) // Pass coordinates to viewModel
        
    }
    
    var body: some View {
        VStack {
            Form {
                
                
                Section {
                    
                    ZStack(alignment: .leading) {
                        TextField("Enter place name", text: $viewModel.placeName)
                        ClearButton(text: $viewModel.placeName)
                            .padding(.leading, 8)
                    }
                                       
                    
                } header: {
                    Text("Place Name")
                }
                
                Section {
                    TextField("Enter address", text: $viewModel.placeAddress)
                    ClearButton(text: $viewModel.placeAddress)
                        .padding(.leading, 8)
                } header: {
                    Text("Address")
                }
                
                Section {
                    TextEditor(text: $viewModel.journalEntry)
                } header: {
                    Text("Journal Entry")
                }
                
                if(viewModel.isFetchingSuggestions) {
                    HStack {
                        Text("Fetching suggestions")
                            .font(.headline)
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, 8)
                    }
                }
                else if(viewModel.places.isEmpty) {
                    Text("No suggestions found.")
                        .font(.headline)
                }
                else {
                    
                    Section {
                        List {
                            ForEach(viewModel.places.prefix(3)) { place in
                                PlaceRow(place: place)
                                    .onTapGesture {
                                        viewModel.autofillPlace(placeName: place.placeName, placeAddress: place.placeAddress)
                                    }
                            }
                        }
                        Text("Tap a suggestion to autofill the form.")
                        
                    } header: {
                        HStack {
                            Text("Suggestions")
                            
                            Spacer()
                            
                            if(viewModel.places.count > 3) {
                                Button {
                                    viewModel.showSuggestionsSheet()
                                } label: {
                                    Text("Show all")
                                }
                            }
                            
                        }
                    }
                }
                
                Section {
                    Button("Confirm") {
                        addJournalEntry()
                    }
                }
            }
        }
        .navigationTitle("New Journal")
        .onAppear {
            viewModel.fetchNearbyPlaces()
        }
        .sheet(isPresented: $viewModel.isShowingSuggestionsSheet) {
            PlaceListView(showSheet: $viewModel.isFetchingSuggestions, placeName: $viewModel.placeName, placeAddress: $viewModel.placeAddress, places: viewModel.places)
        }
    }
    
    func addJournalEntry() {
        // context.insert(item)
    }
}

#Preview {
    NewPlaceView(showingSheet: .constant(true), longitude: 0.0, latitude: 0.0)
}
