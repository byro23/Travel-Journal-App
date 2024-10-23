//
//  NewPlaceSheet.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import SwiftUI

struct NewPlaceView: View {
    
    @StateObject var viewModel = NewPlaceViewModel()
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Place Name", text: $viewModel.placeName)
                    
                } header: {
                    Text("Place Information")
                }
                Section {
                    TextEditor(text: $viewModel.journalEntry)
                } header: {
                    Text("Journal Entry")
                }
            }
        }
        .navigationTitle("New Journal")
    }
}

#Preview {
    NewPlaceView()
}
