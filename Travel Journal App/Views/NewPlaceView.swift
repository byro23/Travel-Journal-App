//
//  NewPlaceSheet.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import SwiftUI

struct NewPlaceView: View {
    
    enum FocusField: Hashable {
        case title, placeName, placeAddress, journalEntry
    }
    
    @StateObject var viewModel: NewPlaceViewModel
    @Environment(\.modelContext) private var context // For using Swift Data
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var mapViewModel: MapViewModel
    @Binding var showingSheet: Bool
    @FocusState private var focusField: FocusField?
    
    // New state to control background color animation
    @State private var isAutoFillingPlaceName = false
    @State private var isAutoFillingPlaceAddress = false

    
    init(showingSheet: Binding<Bool>, longitude: Double, latitude: Double) {
        self._showingSheet = showingSheet // Assign the binding variable
        _viewModel = StateObject(wrappedValue: NewPlaceViewModel(longitude: longitude, latitude: latitude)) // Pass coordinates to viewModel
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    
                    Section {
                        TextField("Journal title", text: $viewModel.journalTitle)
                            .focused($focusField, equals: .title)
                            .background(focusField == .title ? Color.blue.opacity(0.1) : Color.clear)
                            .animation(.easeInOut, value: focusField)
                        
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
                        
                        TextField("Write up a journal entry for your trip!", text: $viewModel.journalEntry, axis: .vertical)
                        
                    } header: {
                        Text("Journal Entry")
                    }
                    
                    Section {
                        
                    } header: {
                        Text("Upload Images")
                    }
                    
                    Section {
                        
                        ZStack(alignment: .leading) {
                            TextField("Enter place name", text: $viewModel.placeName)
                                .focused($focusField, equals: .placeName)
                                .background(focusField == .placeName ? Color.blue.opacity(0.1) : Color.clear)
                                .background(isAutoFillingPlaceName ? Color.blue.opacity(0.1) : Color.clear)
                                .animation(.easeInOut, value: focusField)
                                .animation(.easeInOut(duration: 0.2), value: isAutoFillingPlaceAddress)
                
                            ClearButton(text: $viewModel.placeName)
                                .padding(.leading, 8)
                        }
                        
                        ZStack {
                            TextField("Enter address", text: $viewModel.placeAddress)
                                .focused($focusField, equals: .placeAddress)
                                .background(focusField == .placeAddress ? Color.blue.opacity(0.1) : Color.clear)
                                .background(isAutoFillingPlaceAddress ? Color.blue.opacity(0.1) : Color.clear)
                                .animation(.easeInOut, value: focusField)
                                .animation(.easeInOut(duration: 0.2), value: isAutoFillingPlaceAddress)
                            
                            ClearButton(text: $viewModel.placeAddress)
                                .padding(.leading, 8)
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
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundStyle(.yellow)
                                Text("No suggestions found.")
                            }
                        }
                        else {
                            List {
                                HStack {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundStyle(.yellow)
                                    Text("Tap a suggestion to autofill the form.")
                                }
                                ForEach(viewModel.places.prefix(3)) { place in
                                    PlaceRow(place: place)
                                        .onTapGesture {
                                            focusField = nil
                                            viewModel.autofillPlace(placeName: place.placeName, placeAddress: place.placeAddress)
                                            animateAutoFill()
                                        }
                                }
                            }
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
                    
                    AnimatedButton(buttonText: "Save") {
                        if let userId = authController.currentUser?.id {
                            viewModel.saveJournalFirestore(userId: userId)
                        }
                        
                        saveJournalSwiftData()
                        
                        mapViewModel.tappedCoordinates = nil
                        viewModel.isJournalSaved = true
                        
                    }
                    .disabled(!viewModel.validForm)
                    .opacity(viewModel.validForm ? 1 : 0.7)
                }
            }
            .navigationTitle("New Journal")
            .onAppear {
                viewModel.fetchNearbyPlaces()
            }
            .sheet(isPresented: $viewModel.isShowingSuggestionsSheet) {
                PlaceListView(showSheet: $viewModel.isShowingSuggestionsSheet, placeName: $viewModel.placeName, placeAddress: $viewModel.placeAddress, places: viewModel.places)
            }
            .alert("Journal saved successfully!", isPresented: $viewModel.isJournalSaved) {
                Button("OK") {
                    showingSheet = false
                }
            }
        }
        
    }
    
    func saveJournalSwiftData() {
        
        if let userId = authController.currentUser?.id {
            let journal = JournalSwiftData(journalTitle: viewModel.journalTitle, journalEntry: viewModel.journalEntry, date: viewModel.journalDate, placeName: viewModel.placeName, address: viewModel.placeAddress, latitude: viewModel.placeLatitude, longitude: viewModel.placeLongitude, userId: userId, imageReferences: [""])
            
                context.insert(journal)
        }
        else {
            print("Unable to save locally: user unauthenticated. ")
        }
        
        
    }
    
    func animateAutoFill() {
        withAnimation {
            isAutoFillingPlaceName = true
            isAutoFillingPlaceAddress = true
        }
                
        // Reset the background color after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                isAutoFillingPlaceName = false
                isAutoFillingPlaceAddress = false
            }
        }
    }
}

#Preview {
    NewPlaceView(showingSheet: .constant(true), longitude: 0.0, latitude: 0.0)
}
