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
    @Environment(\.modelContext) private var context // For using Swift Data
    @Query private var journals: [Journal] = []
    
    let initialPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        )
    )
    
    var body: some View {
        
        VStack{
            HeaderView()
            MapReader { proxy in
                Map(initialPosition: initialPosition) {
                    
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        viewModel.tappedCoordinates = coordinate
                        viewModel.tappedMap = true
                    }
                }
            }
            
        }
        .confirmationDialog("Create new journal?", isPresented: $viewModel.tappedMap, actions: {
            Button("Create journal at this location", role: .none) {
                viewModel.showNewPlaceSheet = true
            }
            Button("Cancel", role: .cancel) { }
        })
        .sheet(isPresented: $viewModel.showNewPlaceSheet) {
            NewPlaceView(showingSheet: $viewModel.showNewPlaceSheet, longitude: viewModel.tappedCoordinates?.longitude ?? 0.0, latitude: viewModel.tappedCoordinates?.latitude ?? 0.0)
        }
        
        
        
    }
}

#Preview {
    MapView()
}
