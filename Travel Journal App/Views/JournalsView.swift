//
//  JournalsView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import SwiftUI
import MapKit

struct JournalsView: View {
    
    @StateObject var viewModel = JournalsViewModel()
    @Environment(\.modelContext) private var context
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    @EnvironmentObject var mapViewModel: MapViewModel
    
    var body: some View {
        VStack {
            // Search and Filter Section
            HStack {
                FloatingTextField(placeHolder: "Search journals", textInput: $viewModel.searchText)
                    .padding()
                    .onChange(of: viewModel.searchText) {
                        viewModel.applyFiltersAndSearch()
                    }
                
                VStack {
                    Menu("Filter by") {
                        Button("Favourites") {
                            viewModel.updateFilter(to: .favourites)
                        }
                        .disabled(viewModel.filterState == .favourites)
                        
                        Button("Date") {
                            viewModel.updateFilter(to: .date)
                        }
                        .disabled(viewModel.filterState == .date)
                    }
                    
                    Menu("Order by") {
                        Button("Reset") {
                            viewModel.updateFilter(to: .none)
                        }
                    }
                }
                .padding()
            }
            
            // List of Journals
            if !viewModel.journals.isEmpty {
                List {
                    ForEach(viewModel.journals) { journal in
                        JournalRow(journal: journal)
                            .onTapGesture {
                                viewModel.wasJournalTapped = true
                                viewModel.tappedJournal = journal
                            }
                    }
                }
            } else {
                Text("No journals to show.")
                Button("Go to map?") {
                    navigationController.currentTab = .map
                }
            }
            
            Spacer()
        }
        .navigationTitle("All Journals")
        .onAppear {
            viewModel.fetchJournals(journals: mapViewModel.journals)
        }
        .confirmationDialog("Options", isPresented: $viewModel.wasJournalTapped) {
            Button("View Journal") {
                viewModel.isNavigateToJournal = true
            }
            Button("Go to position on map") {
                if let journal = viewModel.tappedJournal {
                    let region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: journal.latitude, longitude: journal.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    mapViewModel.cameraPosition = .region(region)
                    navigationController.currentTab = .map
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.isNavigateToJournal) {
            if let journal = viewModel.tappedJournal {
                JournalDetailedView(journal: journal)
            }
        }
    }
}

