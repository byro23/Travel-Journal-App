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
    
    // State for favorite status, map region, and images
    @State private var isFavorite: Bool
    @State private var region: MKCoordinateRegion
    @State private var images: [UIImage] = []
    @State private var isLoadingImages = true
    
    // State for fullscreen image view
    @State private var selectedImage: IdentifiableImage? = nil
    
    // State for presenting edit view
    @State private var isPresentingEditView = false
    
    init(journal: JournalSwiftData) {
        self.journal = journal
        _isFavorite = State(initialValue: journal.isFavourite)
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
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(images, id: \.self) { image in
                                Button(action: {
                                    print("Image tapped")
                                    selectedImage = IdentifiableImage(image: image)
                                    print("Selected image set, opening fullscreen")
                                    print("Selected image is \(selectedImage)")
                                }) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 280, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                }
                
                Button("Edit") { // Add Edit button
                    isPresentingEditView = true
                }
                .foregroundColor(.blue)
            }
        }
        // Full-screen cover for displaying selected image
        .fullScreenCover(item: $selectedImage) { identifiableImage in
            FullScreenImageView(image: identifiableImage.image, isPresented: $selectedImage)
        }
        // Sheet for editing journal
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                EditJournalView(journal: journal)
            }
        }
    }
    
    struct FullScreenImageView: View {
        let image: UIImage
        @Binding var isPresented: IdentifiableImage?
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {
                    isPresented = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        journal.isFavourite = isFavorite
        try? context.save()  // Save changes to SwiftData
    }
    
    private func fetchImages() {
        let storage = Storage.storage()
        var loadedImages: [UIImage] = []
        
        let dispatchGroup = DispatchGroup()
        
        for imageRef in journal.imageReferences {
            dispatchGroup.enter()
            let storageRef = storage.reference().child(imageRef)
            
            storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error fetching image data: \(error.localizedDescription)")
                } else if let data = data, let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.images = loadedImages
            self.isLoadingImages = false  // Update loading state after loading completes
            print("Images loaded: \(self.images.count)")
        }
    }
}

// model for displaying image in fullScreen

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

#Preview {
    NavigationView {
        JournalDetailedView(journal: JournalSwiftData.MOCK_JOURNAL)
    }
}
