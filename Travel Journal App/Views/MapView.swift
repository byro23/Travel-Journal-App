//
//  MapView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @EnvironmentObject var viewModel: MapViewModel
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    @Environment(\.modelContext) private var context
    @Query private var journals: [JournalSwiftData] = []
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    @State private var isSearching = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Welcome Card
            VStack(spacing: 8) {
                // User greeting with wave emoji
                HStack {
                    Text("Hello, ")
                        .foregroundColor(.secondary) +
                    Text(authController.currentUser?.name ?? "Preview name")
                        .fontWeight(.semibold)
                    
                    if #available(iOS 18.0, *) {
                        Image(systemName: "hand.wave.fill")
                            .foregroundStyle(.yellow)
                            .symbolEffect(.bounce, options: .repeating)
                    }
                }
                .font(.title3)
                
                // Instruction card
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    
                    Text("Tap anywhere on the map to add a new journal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Search Area
            VStack(spacing: 0) {
                HStack {
                    ZStack {
                        NonFloatingTextField(placeHolder: "Search", textInput: $viewModel.searchText)
                            .padding()
                            .matchedGeometryEffect(id: "searchField", in: animation)
                        
                        ClearButton(text: $viewModel.searchText)
                            .padding()
                            .padding(.trailing, 10)
                            .opacity(viewModel.searchText.count > 2 ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.searchText)
                }
                
                // Search Results with enhanced animations
                if viewModel.searchSuggestions.count > 3 {
                    VStack(spacing: 0) {
                        List(viewModel.searchSuggestions, id: \.self) { suggestion in
                            PlaceRow(place: Place(placeName: suggestion.title,
                                                placeAddress: suggestion.subtitle,
                                                latitude: 0.0,
                                                longitude: 0.0))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isSearching = false
                                        viewModel.goToSuggestion(suggestion: suggestion)
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                                    removal: .scale(scale: 0.95).combined(with: .opacity)
                                ))
                                .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                    }
                    .background(Color(.systemBackground))
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                } else {
                    // Map Area
                    ZStack {
                        MapReader { proxy in
                            Map(position: $viewModel.cameraPosition) {
                                ForEach(viewModel.journals, id: \.self) { journal in
                                    let coordinate = CLLocationCoordinate2D(
                                        latitude: journal.latitude, longitude: journal.longitude
                                    )
                                    
                                    Annotation(journal.journalTitle, coordinate: coordinate) {
                                        if journal.isFavourite {
                                            VStack(spacing: viewModel.annotationSize * 0.1) {
                                                Button {
                                                    viewModel.tappedAnnotation = true
                                                    viewModel.tappedJournal = journal
                                                } label: {
                                                    VStack(spacing: viewModel.annotationSize * 0.1) {
                                                        Image(systemName: "heart.fill")
                                                            .resizable()
                                                            .frame(width: viewModel.annotationSize * 0.5, height: viewModel.annotationSize * 0.5)
                                                            .foregroundStyle(.red)
                                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                                            .offset(y: viewModel.annotationSize * 0.1)
                                                            .zIndex(1)
                                                        
                                                        Image(systemName: "mappin.circle.fill")
                                                            .resizable()
                                                            .frame(width: viewModel.annotationSize, height: viewModel.annotationSize)
                                                            .foregroundStyle(.red)
                                                    }
                                                }
                                                .background(
                                                    Circle()
                                                        .fill(.white)
                                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                                        .padding(-4)
                                                )
                                                .padding(12)
                                            }
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7),
                                                      value: viewModel.getZoomLevel(viewModel.region.span))
                                        } else {
                                            Button {
                                                viewModel.tappedAnnotation = true
                                                viewModel.tappedJournal = journal
                                            } label: {
                                                Image(systemName: "mappin.circle.fill")
                                                    .resizable()
                                                    .frame(width: viewModel.annotationSize, height: viewModel.annotationSize)
                                                    .foregroundStyle(.orange)
                                            }
                                            .background(
                                                Circle()
                                                    .fill(.white)
                                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                                    .padding(-4)
                                            )
                                            .padding(12)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7),
                                                      value: viewModel.getZoomLevel(viewModel.region.span))
                                        }
                                    }
                                }

                                // New Journal Annotation
                                if let coordinate = viewModel.tappedCoordinates {
                                    Annotation("New Journal", coordinate: coordinate) {
                                        Button {
                                            withAnimation {
                                                viewModel.showNewPlaceSheet = true
                                            }
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .resizable()
                                                .frame(width: viewModel.annotationSize, height: viewModel.annotationSize)
                                                .foregroundStyle(.blue)
                                        }
                                        .background(
                                            Circle()
                                                .fill(.white)
                                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                                .padding(-4)
                                        )
                                    }
                                }
                            }
                            .mapStyle(.standard(elevation: .realistic))
                            .onTapGesture { position in
                                if let coordinate = proxy.convert(position, from: .local) {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.tappedCoordinates = coordinate
                                        viewModel.tappedMap = true
                                    }
                                }
                            }
                            .onMapCameraChange { context in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.region = context.region
                                }
                            }
                        }
                        .opacity(viewModel.searchSuggestions.count > 3 ? 0.3 : 1)
                        .animation(.easeInOut(duration: 0.3),
                                 value: viewModel.searchSuggestions.count > 3)
                        
                        // Overlay blur when searching
                        if viewModel.searchSuggestions.count > 3 {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea()
                                .transition(.opacity)
                        }
                    }
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8),
                      value: viewModel.searchSuggestions.count > 3)
        }
        .confirmationDialog("Create new journal?", isPresented: $viewModel.tappedMap) {
            Button {
                withAnimation {
                    viewModel.showNewPlaceSheet = true
                }
            } label: {
                Label("Create journal here", systemImage: "plus.circle")
            }
            
            Button("Cancel", role: .cancel) {
                withAnimation {
                    viewModel.tappedCoordinates = nil
                }
            }
        } message: {
            Text("Would you like to create a new journal entry at this location?")
        }
        .sheet(isPresented: $viewModel.showNewPlaceSheet) {
            NewJournalView(showingSheet: $viewModel.showNewPlaceSheet,
                        longitude: viewModel.tappedCoordinates?.longitude ?? 0.0,
                        latitude: viewModel.tappedCoordinates?.latitude ?? 0.0)
        }
        .onAppear {
            if let userId = authController.currentUser?.id {
                viewModel.fetchJournals(for: userId, context: context)
            }
        }
        .onChange(of: viewModel.showNewPlaceSheet) { oldValue, newValue in
            if let userId = authController.currentUser?.id {
                viewModel.fetchJournals(for: userId, context: context)
            }
        }
        .navigationDestination(isPresented: $viewModel.tappedAnnotation) {
            if let tappedJournal = viewModel.tappedJournal {
                JournalDetailedView(journal: tappedJournal)
            }
        }
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                isSearching = !newValue.isEmpty
            }
        }
    }
}

#Preview {
    MapView()
        .environmentObject(AuthController())
        .environmentObject(MapViewModel())
}
