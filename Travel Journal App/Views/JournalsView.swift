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
        VStack() {
            HStack {
                FloatingTextField(placeHolder: "Search journals", textInput: $viewModel.searchText)
                    .padding()
                
                VStack {
                    Menu("Filter by") {
                        Button("Favourites") {
                            
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
                            .onTapGesture {
                                viewModel.wasJournalTapped = true
                                viewModel.tappedJournal = journal
                            }
                    }
                }
            }
            else {
                
                Text("No journals to Show")
                
                Button {
                    navigationController.currentTab = .map
                    
                } label: {
                    Text("Go to map?")
                }
                
            }
            
            
            Spacer()
        }
        .navigationTitle("All Journals")
        .onAppear {
            viewModel.fetchJournals(journals: mapViewModel.journals)
        }
        .confirmationDialog("Options", isPresented: $viewModel.wasJournalTapped) {
            Button("View Journal", role: .none) {
                viewModel.isNavigateToJournal = true
            }
            Button("Go to position on map", role: .none) {
                
                let region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: viewModel.tappedJournal!.latitude,
                            longitude: viewModel.tappedJournal!.longitude
                        ),
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.01,  // Closer zoom level
                            longitudeDelta: 0.01
                        )
                )
                mapViewModel.cameraPosition = .region(region)
                navigationController.currentTab = .map
            }
        }
        .navigationDestination(isPresented: $viewModel.isNavigateToJournal) {
            if let journal = viewModel.tappedJournal {
                JournalDetailedView(journal: journal)
            }
            
        }
    }
}

#Preview {
    JournalsView()
        .environmentObject(AuthController())
        .environmentObject(MapViewModel())
}
