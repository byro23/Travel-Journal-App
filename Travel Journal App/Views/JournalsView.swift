//
//  JournalsView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import SwiftUI

struct JournalsView: View {
    
    @StateObject var viewModel = JournalsViewModel()
    @Environment(\.modelContext) private var context
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    @EnvironmentObject var mapViewModel: MapViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                FloatingTextField(placeHolder: "Search journals", textInput: $viewModel.searchText)
                    .padding()
                
                VStack {
                    Menu("Filter by") {
                        Button("Favorites") {
                            
                        }
                        .disabled(viewModel.filterState == .favourites)
                        
                        Button("Date") {
                            
                        }
                        .disabled(viewModel.filterState == .date)
                        
                    }
                    
                    Menu("Order by") {
                        
                    }
                }
                .padding()
            }
            
            if(!viewModel.journals.isEmpty) {
                List {
                    ForEach(viewModel.journals) { journal in
                        JournalRow(journal: journal)
                    }
                }
            }
            
            
            Spacer()
        }
        .navigationTitle("All Journals")
        .onAppear {
            viewModel.fetchJournals(journals: mapViewModel.journals)
        }
    }
}

#Preview {
    JournalsView()
        .environmentObject(AuthController())
        .environmentObject(MapViewModel())
}
