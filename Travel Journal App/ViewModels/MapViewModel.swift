//
//  MapViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import Foundation
import MapKit
import _MapKit_SwiftUI

class MapViewModel: ObservableObject {
    
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    
    private let mapView = MKMapView() // Allows for interaction with the map
    
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var showNewPlaceSheet = false
    
    
    func convertTapToCoordinates(at point: CGPoint) -> CLLocationCoordinate2D {
        
        return mapView.convert(point, toCoordinateFrom: mapView)
    }
}
