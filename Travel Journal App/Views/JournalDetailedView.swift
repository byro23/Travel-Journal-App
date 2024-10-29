//
//  JournalDetailedView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import SwiftUI
import FirebaseStorage
import MapKit

struct JournalDetailedView: View {
    let journal: JournalSwiftData
    
    @Environment(\.modelContext) private var context
    
    // Add state for favorite status
    @State private var isFavorite: Bool
    @State private var region: MKCoordinateRegion
    @State private var images: [UIImage] = []
    
    @State private var isLoadingImages = true  // State to track image loading

    init(journal: JournalSwiftData) {
        self.journal = journal
        _isFavorite = State(initialValue: journal.isFavourite) // Initialize with current favorite status
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: journal.latitude,
                longitude: journal.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(journal.date.formatted(date: .long, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Images Section
                if isLoadingImages {
                    ProgressView("Loading images...")
                        .padding()
                } else if images.isEmpty {
                    Text("No Images Available")
                        .foregroundColor(.secondary)
                        .padding()
                }
                else{
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(images, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 280, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Location Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text(journal.placeName)
                    }
                    
                    Text(journal.address)
                        .foregroundColor(.secondary)
                    
                    Map(coordinateRegion: $region, annotationItems: [journal]) { journal in
                        MapMarker(coordinate: CLLocationCoordinate2D(
                            latitude: journal.latitude,
                            longitude: journal.longitude
                        ))
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // Journal Entry Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Journal Entry")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(journal.journalEntry)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            fetchImages()
        }
        .navigationTitle(journal.journalTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                }
            }
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        journal.isFavourite = isFavorite
        // Save changes to SwiftData
        try? context.save()
    }
    
    private func fetchImages() {
        let storage = Storage.storage()
        var loadedImages: [UIImage] = []
        
        let dispatchGroup = DispatchGroup()
        
        for imageRef in journal.imageReferences {
            dispatchGroup.enter()
            let storageRef = storage.reference().child(imageRef)
            
            // Fetch the image data from Firebase Storage
            storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error fetching image data: \(error.localizedDescription)")
                } else if let data = data, let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        // Update the images array after all downloads complete
        dispatchGroup.notify(queue: .main) {
            self.images = loadedImages
            self.isLoadingImages = false  // Set to false after loading completes

        }
    }
}

#Preview {
    NavigationView {
        JournalDetailedView(journal: JournalSwiftData.MOCK_JOURNAL)
    }
}
