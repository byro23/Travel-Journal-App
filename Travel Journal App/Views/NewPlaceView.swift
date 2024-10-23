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
                    TextField("Enter place name", text: $viewModel.placeName)
                    
                    Text("Suggestions")
                        .font(.headline)
                    
                    if(!viewModel.placeResults.isEmpty) {
                        
                    }
                    
                } header: {
                    Text("Place Information")
                }
                Section {
                    TextEditor(text: $viewModel.journalEntry)
                } header: {
                    Text("Journal Entry")
                }
                
                Button("Add Entry") {
                    addJournalEntry()
                }
            }
        }
        .navigationTitle("New Journal")
        .onAppear {
            viewModel.fetchNearByPlaces()
        }
    }
    
    func addJournalEntry() {
        // context.insert(item)
    }
}

#Preview {
    NewPlaceView(showingSheet: .constant(true), longitude: 0.0, latitude: 0.0)
}
