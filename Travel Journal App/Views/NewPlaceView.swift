//
//  NewPlaceSheet.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import SwiftUI

struct NewPlaceView: View {
    
    @StateObject var viewModel: NewPlaceViewModel
    @Environment(\.modelContext) private var context // For using Swift Data
    @Binding var showingSheet: Bool
    @FocusState private var isFocused: Bool
    
    
    init(showingSheet: Binding<Bool>, longitude: Double, latitude: Double) {
        self._showingSheet = showingSheet // Assign the binding variable
        _viewModel = StateObject(wrappedValue: NewPlaceViewModel(longitude: longitude, latitude: latitude)) // Pass coordinates to viewModel
        
    }
    
    var body: some View {
        VStack {
            Form {
                
                Section {
                    TextField("Journal title", text: $viewModel.journalTitle)
                        .focused($isFocused)
                        .background(isFocused ? Color.blue.opacity(0.1) : Color.clear)
                        .animation(.easeInOut, value: isFocused)
                    
                    DatePicker(
                            "Date",
                            selection: $viewModel.journalDate,
                            displayedComponents: [.date,]
                        )
                    
                    // Date picker
                } header: {
                    Text("Journal Details")
                }
                
                Section {
                    ZStack(alignment: .topLeading) {
                        if viewModel.journalEntry.isEmpty {
                            Text("Enter your journal entry...")
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $viewModel.journalEntry)
                    }
                } header: {
                    Text("Journal Entry")
                }
                
                Section {
                    
                } header: {
                    Text("Images")
                }
                
                Section {
                    
                    ZStack(alignment: .leading) {
                        TextField("Enter place name", text: $viewModel.placeName)
                        ClearButton(text: $viewModel.placeName)
                            .padding(.leading, 8)
                    }
                    
                    ZStack {
                        TextField("Enter address", text: $viewModel.placeAddress)
                    }
                    
                } header: {
                    Text("Place Details")
                }
                
                Section {
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
                            //.font(.headline)
                    }
                    else {
                        List {
                            ForEach(viewModel.places.prefix(3)) { place in
                                PlaceRow(place: place)
                                    .onTapGesture {
                                        viewModel.autofillPlace(placeName: place.placeName, placeAddress: place.placeAddress)
                                    }
                            }
                        }
                        Text("Tap a suggestion to autofill the form.")
                    }
                    
                } header: {
                    HStack {
                        Text("Nearby Places")
                        
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
            Button {
                
            } label: {
                Text("Save")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
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
