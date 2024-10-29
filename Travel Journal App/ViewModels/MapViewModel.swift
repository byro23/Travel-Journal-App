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
import Combine
import SwiftUICore

@MainActor
class MapViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    private let mapView = MKMapView()
    
    @Published var tappedCoordinates: CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    
    @Published var previousRegion: MKCoordinateRegion?
    
    let worldwideRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
    
    @Published var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: defaultRegion,
            span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        )
    )
    @Published var showNewPlaceSheet = false
    @Published var tappedMap = false
    @Published var journals: [JournalSwiftData] = []
    @Published var tappedAnnotation = false
    @Published var tappedJournal: JournalSwiftData?
    
    var annotationSize: CGFloat {
        let zoomLevel = getZoomLevel(self.region.span)
        if zoomLevel > 2.0 {
            return 10
        } else if zoomLevel > 0.2 {
            return 20
        } else {
            return 30
        }
    }

    @Published var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                // Only restore previous region if we're clearing from an active search
                if !searchSuggestions.isEmpty {
                    searchSuggestions = []  // Clear suggestions first
                    if let previousRegion = previousRegion {
                        withAnimation(.easeOut(duration: 0.3)) {
                            region = previousRegion
                            cameraPosition = .region(previousRegion)
                        }
                        self.previousRegion = nil
                    }
                }
            } else {
                // Store current region only when starting a new search
                if searchSuggestions.isEmpty {
                    previousRegion = region
                }
                searchCompleter.queryFragment = searchText
            }
        }
    }

    
    @Published var searchSuggestions: [MKLocalSearchCompletion] = []

    private let searchCompleter = MKLocalSearchCompleter()
    
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setupSearchCompleter()

        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newText in
                if newText.isEmpty {
                    self?.searchSuggestions = []  // Clear suggestions
                } else {
                    self?.searchCompleter.queryFragment = newText
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        searchCompleter.region = worldwideRegion
    }

    // Delegate method to handle search results
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchSuggestions = completer.results
    }

    // Delegate method to handle errors
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search Completer Error: \(error.localizedDescription)")
    }

    func convertTapToCoordinates(at point: CGPoint) -> CLLocationCoordinate2D {
        mapView.convert(point, toCoordinateFrom: mapView)
    }

    func fetchJournals(for userId: String, context: ModelContext) {
        let request = FetchDescriptor<JournalSwiftData>(
            predicate: #Predicate { $0.userId == userId }
        )

        do {
            journals = try context.fetch(request)
            print("Journal count for user \(userId): \(journals.count)")
        } catch {
            print("Failed to fetch journals: \(error.localizedDescription)")
        }
    }
    
    func goToSuggestion(suggestion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] response, error in
            guard let self = self,
                  let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            
            // Run all UI updates on main thread
            DispatchQueue.main.async {
                // Clear suggestions first
                withAnimation(.easeOut(duration: 0.2)) {
                    self.searchSuggestions = []
                }
                
                // Move to the new location
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        let newRegion = MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        self.region = newRegion
                        self.cameraPosition = .region(newRegion)
                    }
                    
                    // Clear search text after map movement starts
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        // Don't restore previous region when clearing after successful search
                        self.previousRegion = nil
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.searchText = ""
                        }
                    }
                }
            }
        }
    }
    
    func getZoomLevel(_ span: MKCoordinateSpan) -> Double {
        return span.latitudeDelta + span.longitudeDelta
    }
}
