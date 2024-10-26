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
    @StateObject var viewModel = MapViewModel()
    @EnvironmentObject var authController: AuthController
    @Environment(\.modelContext) private var context // For using Swift Data
    @Query private var journals: [JournalSwiftData] = []
    
    let initialPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        )
    )
    
    var body: some View {
        
        VStack{
            HeaderView()
            
            Text("Hello, \(authController.currentUser?.name ?? "Preview name")")
            
            MapReader { proxy in
                Map(initialPosition: initialPosition) {
                    
                    
                    ForEach(viewModel.journals, id: \.self) { journal in
                            let coordinate = CLLocationCoordinate2D(
                                latitude: journal.latitude, longitude: journal.longitude
                            )
                        
                        Annotation(journal.journalTitle, coordinate: coordinate) {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .resizable() // Make the image scalable
                                    .foregroundStyle(.red)
                                    .frame(width: 25, height: 25) // Set the desired size
                                    .padding(4) // Optional padding for a better touch area
                            }
                        }
                    }
                    
                    if let coordinate = viewModel.tappedCoordinates {
                        Annotation("New Journal", coordinate: coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 25, height: 25)
                        }
                    }
                    
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        viewModel.tappedCoordinates = coordinate
                        viewModel.tappedMap = true
                    }
                }
            }
            
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.yellow)
                Text("Tap anywhere on the map to add a new journal.")
            }
            .padding(.top)
            .padding(.bottom)
            
        }
        .confirmationDialog("Create new journal?", isPresented: $viewModel.tappedMap, actions: {
            Button("Create journal at this location", role: .none) {
                viewModel.showNewPlaceSheet = true
            }
            Button("Cancel", role: .cancel) {
                viewModel.tappedCoordinates = nil
            }
        })
        .sheet(isPresented: $viewModel.showNewPlaceSheet) {
            NewPlaceView(showingSheet: $viewModel.showNewPlaceSheet, longitude: viewModel.tappedCoordinates?.longitude ?? 0.0, latitude: viewModel.tappedCoordinates?.latitude ?? 0.0)
        }
        .onAppear {
            if let userId = authController.currentUser?.id {
                viewModel.fetchJournals(for: userId, context: context)
            }
            viewModel.tappedCoordinates = nil
            
        }
        
        
        
    }
}

#Preview {
    MapView()
    .environmentObject(AuthController())
}
