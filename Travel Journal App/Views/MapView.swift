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
                    
                    if let coordinate = viewModel.tappedCoordinates {
                        Annotation("New Journal", coordinate: coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.red)
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
                viewModel.tappedCoordinates = nil
            }
            Button("Cancel", role: .cancel) {
                viewModel.tappedCoordinates = nil
            }
        })
        .sheet(isPresented: $viewModel.showNewPlaceSheet) {
            NewPlaceView(showingSheet: $viewModel.showNewPlaceSheet, longitude: viewModel.tappedCoordinates?.longitude ?? 0.0, latitude: viewModel.tappedCoordinates?.latitude ?? 0.0)
        }
        
        
        
    }
}

#Preview {
    MapView()
                    .environmentObject(AuthController())
}
