//
//  MapView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    
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
                        
                    }
                }
            }
            
        }
        //.sheet(item: $viewModel.showNewPlaceSheet, content: )
        
        
        
    }
}

#Preview {
    MapView()
}
