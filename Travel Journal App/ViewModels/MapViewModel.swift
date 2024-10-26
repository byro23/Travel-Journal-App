//
//  MapViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import Foundation
import MapKit
import _MapKit_SwiftUI
import SwiftData

class MapViewModel: ObservableObject {
    
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    
    private let mapView = MKMapView() // Allows for interaction with the map
    
    @Published var tappedCoordinates: CLLocationCoordinate2D?
    
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var showNewPlaceSheet = false
    @Published var tappedMap = false
    @Published var journals: [JournalSwiftData] = []
    
    
    
    func convertTapToCoordinates(at point: CGPoint) -> CLLocationCoordinate2D {
        
        return mapView.convert(point, toCoordinateFrom: mapView)
    }
    
    
    func fetchJournals(for userId: String, context: ModelContext) {
        let request = FetchDescriptor<JournalSwiftData>(
            predicate: #Predicate { $0.userId == userId } // Filter by userId
        )

        do {
            journals = try context.fetch(request)
            print("Journal count for user \(userId): \(journals.count)")
        } catch {
            print("Failed to fetch journals: \(error.localizedDescription)")
        }
    }

}
