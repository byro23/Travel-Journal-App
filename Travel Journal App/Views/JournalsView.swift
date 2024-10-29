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
                
                Menu("Order by") {
                    Button("Date") {
                        viewModel.orderState = .date
                        viewModel.applyFiltersAndSearch()
                    }
                    .disabled(viewModel.orderState == .date)
                  
                    Button("Title") {
                        viewModel.orderState = .title
                        viewModel.applyFiltersAndSearch()
                    }
                    .disabled(viewModel.orderState == .title)
                    
                    Button("Place name") {
                        viewModel.orderState = .placeName
                        viewModel.applyFiltersAndSearch()
                    }
                    .disabled((viewModel.orderState == .placeName))
                    
                    Button("Address") {
                        viewModel.orderState = .address
                        viewModel.applyFiltersAndSearch()
                    }
                    .disabled(viewModel.orderState == .address)
                    
                    Button("Custom order") {
                        viewModel.orderState = .custom
                        viewModel.applyFiltersAndSearch()
                    }
                    .disabled(viewModel.orderState == .custom)
                }
                .padding()
            }
            
            if(!viewModel.allJournals.isEmpty) {
                HStack {
                    FilterButton(title: "All", isSelected: viewModel.filterState == .all) {
                        viewModel.filterState = .all
                        viewModel.applyFiltersAndSearch()
                    }
                    
                    FilterButton(title:"Favourites", isSelected: viewModel.filterState == .favourites) {
                        viewModel.filterState = .favourites
                        viewModel.applyFiltersAndSearch()
                    }
                    
                    Spacer()
                    
                    if viewModel.orderState == .custom {
                        Text("Drag to reorder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .animation(.easeInOut, value: viewModel.orderState)
            }
            
            
            // Animated List of Journals
            if !viewModel.journals.isEmpty {
                List {
                    ForEach(viewModel.journals) { journal in
                        JournalRow(journal: journal)
                            .onTapGesture {
                                viewModel.wasJournalTapped = true
                                viewModel.tappedJournal = journal
                            }
                            // Delete function
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteJournal(journal, context: context)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.7)),
                                removal: .opacity.animation(.easeOut(duration: 0.2))
                            ))
                    }
                    .if(viewModel.orderState == .custom) { view in
                        view.onMove(perform: viewModel.moveItem)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.journals)
                .environment(\.editMode, viewModel.orderState == .custom ? .constant(.active) : .constant(.inactive))
            } else {
                VStack {
                    Text("No journals to show.")
                        .transition(.scale.combined(with: .opacity))
                    Button("Go to map?") {
                        navigationController.currentTab = .map
                    }
                }
                .padding()
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: viewModel.journals.isEmpty)
            }
            
            Spacer()
        }
        .navigationTitle("All Journals")
        .onAppear {
            viewModel.fetchJournals(journals: mapViewModel.journals)
            mapViewModel.tappedCoordinates = nil

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

// Helper extension for conditional modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    JournalsView()
        .environmentObject(NavigationController())
        .environmentObject(AuthController())
        .environmentObject(MapViewModel())
}
