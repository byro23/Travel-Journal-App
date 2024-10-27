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
    @Environment(\.modelContext) private var context
    @Query private var journals: [JournalSwiftData] = []
    @Environment(\.colorScheme) var colorScheme
    
    private func getZoomLevel(_ span: MKCoordinateSpan) -> Double {
        return span.latitudeDelta + span.longitudeDelta
    }
    
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
                    } else {
                        // Fallback on earlier versions
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
            
            // Map
            MapReader { proxy in
                Map(position: $viewModel.cameraPosition) {
                    ForEach(viewModel.journals, id: \.self) { journal in
                        let coordinate = CLLocationCoordinate2D(
                            latitude: journal.latitude, longitude: journal.longitude
                        )
                        
                        Annotation(journal.journalTitle, coordinate: coordinate) {
                            VStack(spacing: 4) {
                                let size: CGFloat = {
                                    let zoomLevel = getZoomLevel(viewModel.region.span)
                                    if zoomLevel > 2.0 {
                                        return 8
                                    } else if zoomLevel > 0.2 {
                                        return 20
                                    } else {
                                        return 30
                                    }
                                }()
                                
                                if journal.isFavourite {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .frame(width: size * 0.8, height: size * 0.8)
                                        .foregroundStyle(.red)
                                        .shadow(radius: 2)
                                        .offset(y: -size * 0.4)
                                }
                                
                                Image(systemName: "mappin.circle.fill")
                                    .resizable()
                                    .frame(width: size, height: size)
                                    .foregroundStyle(journal.isFavourite ? .red : .orange)
                                    .shadow(radius: 2)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: size * 0.1)
                                    )
                            }
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: getZoomLevel(viewModel.region.span))
                        }
                    }
                    
                    if let coordinate = viewModel.tappedCoordinates {
                        
                        let size: CGFloat = {
                            let zoomLevel = getZoomLevel(viewModel.region.span)
                            if zoomLevel > 2.0 {
                                return 8
                            } else if zoomLevel > 0.2 {
                                return 20
                            } else {
                                return 30
                            }
                        }()
                        
                        Annotation("New Journal", coordinate: coordinate) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: size, height: size)
                                    .foregroundStyle(.blue)
                                    .background(Circle().fill(.white))
                                    .shadow(radius: 2)
                            }
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
            NewPlaceView(showingSheet: $viewModel.showNewPlaceSheet,
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
    }
}

#Preview {
    MapView()
        .environmentObject(AuthController())
        .environmentObject(MapViewModel())
}
