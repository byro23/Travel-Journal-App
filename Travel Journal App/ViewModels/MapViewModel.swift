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

class MapViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    private let mapView = MKMapView()
    
    @Published var tappedCoordinates: CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
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

    @Published var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                searchSuggestions = []  // Clear suggestions when search text is empty
            } else {
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
        searchCompleter.region = region
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
        print("Got here")
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                self.searchText = ""
                self.cameraPosition = .region(self.region)
            }
        }
    }
}
