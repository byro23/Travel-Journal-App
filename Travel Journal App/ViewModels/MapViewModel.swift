//
//  MapViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import Foundation
import MapKit

class MapViewModel: ObservableObject {
    
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    
    
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
}
