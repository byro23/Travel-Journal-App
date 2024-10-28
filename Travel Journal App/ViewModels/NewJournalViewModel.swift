//
//  NewPlaceViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation
import MapKit
import PhotosUI
import FirebaseStorage
import SwiftUI


class NewJournalViewModel: ObservableObject {
    

    @Published var journalTitle: String = ""
    @Published var journalDate: Date = Date()
    @Published var placeName: String = ""
    @Published var placeAddress: String = ""
    @Published var journalEntry: String = ""
    @Published var places: [Place] = []
    @Published var isFetchingSuggestions = false
    @Published var isJournalSaved = false
    
    @Published var isShowingSuggestionsSheet = false
    @Published var isFavourite: Bool = false
    
    var placeLongitude: Double = 0.0
    var placeLatitude: Double = 0.0
    
    @Published var imageReferences: [String] = []

    

    
    var validForm: Bool {
        !journalTitle.isEmpty && !placeName.isEmpty && !placeAddress.isEmpty && !journalEntry.isEmpty
    }
    
    init(longitude: Double, latitude: Double) {
        placeLongitude = longitude
        placeLatitude = latitude
    }
    
    func fetchNearbyPlaces() {
        isFetchingSuggestions = true
        
        print("Latitude: \(placeLatitude) Longitude: \(placeLongitude)")
        
        let latitudeDelta = 1 / 111.0
        let longitudeDelta = 1 / (111.0 * cos(placeLatitude * .pi / 180))
        
        
        let searchSpan = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let searchRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: placeLatitude, longitude: placeLongitude), span: searchSpan)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = searchRegion
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.naturalLanguageQuery = "Things to do"
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Search error: \(String(describing: error?.localizedDescription))")
                self.isFetchingSuggestions = false
                return
            }
            
            let centerLocation = CLLocation(latitude: self.placeLatitude, longitude: self.placeLongitude)
            
            let fetchedPlaces = response.mapItems.compactMap { mapItem -> Place? in
                guard let name = mapItem.name else { return nil }
                let coordinate = mapItem.placemark.coordinate
                let address = mapItem.placemark.title ?? "No address available"
                
                // Calculate distance from center location
                let placeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = centerLocation.distance(from: placeLocation) // Distance in meters
                
                guard distance <= 1000 else { return nil } // Filter out places > 1 km away (necessary unless we target iOS 18 minimum)
                
                return Place(placeName: name, placeAddress: address, latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
            
            DispatchQueue.main.async {
                self.places = fetchedPlaces
                self.isFetchingSuggestions = false
            }
        }
        
    }
    
    func showSuggestionsSheet() {
        isShowingSuggestionsSheet = true
    }
    
    func autofillPlace(placeName: String, placeAddress: String) {
        self.placeName = placeName
        self.placeAddress = placeAddress
    }
    
    // upload images to storage and add references in imageReferences array
    func uploadImage(selectedImage: UIImage, completion: @escaping (Bool) -> Void) {
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            completion(false)
            return
        }
        
        let storageRef = Storage.storage().reference()
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        fileRef.putData(imageData, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                // Save file path to imageReferences array
                self.imageReferences.append(path)
                completion(true)  // Upload succeeded
            } else {
                completion(false)  // Upload failed
            }
        }
    }

//    func uploadImage(_ selectedImage: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
//            // Create storage reference
//            let storageRef = Storage.storage().reference()
//            let imageData = selectedImage.jpegData(compressionQuality: 0.8)
//            
//            guard let imageData = imageData else {
//                completion(.failure(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data is nil"])))
//                return
//            }
//            
//            // Specify file path and name
//            let path = "images/\(UUID().uuidString).jpg"
//            let fileRef = storageRef.child(path)
//            
//            // Upload data to storage
//            fileRef.putData(imageData, metadata: nil) { metadata, error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    // Append the image reference (path) to the array
//                    self.imageReferences.append(path)
//                    completion(.success(path))
//                }
//            }
//        }
    
    func saveJournalFirestore(userId: String) {
        let journal = Journal(journalTitle: journalTitle, journalEntry: journalEntry, date: journalDate,
                              placeName: placeName, address: placeAddress, latitude: placeLatitude, longitude: placeLongitude, userId: userId, imageReferences: imageReferences, isFavourite: isFavourite)
        
        do {
            try FirebaseManager.shared.addDocument(object: journal, toCollection: FirestoreCollection.journals.rawValue, forUserId: userId)
        }
        catch {
            print("Error saving journal to Firestore: \(error.localizedDescription)")
        }
        
    }

    
    func resetFields() {
        journalTitle = ""
        journalEntry = ""
        placeName = ""
        placeAddress = ""
    }
    
    
    
    
}
