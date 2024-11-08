//
//  NewPlaceSheet.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import SwiftUI

import PhotosUI

struct NewJournalView: View {

    enum FocusField: Hashable {
        case title, placeName, placeAddress, journalEntry
    }
    
    @StateObject var viewModel: NewJournalViewModel
    @Environment(\.modelContext) private var context
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var mapViewModel: MapViewModel
    @Binding var showingSheet: Bool
    @FocusState private var focusField: FocusField?
    
    @State private var isAutoFillingPlaceName = false
    @State private var isAutoFillingPlaceAddress = false
    @State private var placeNameScale: CGFloat = 1.0
    @State private var addressScale: CGFloat = 1.0
    @State private var autofillBackgroundOpacity: Double = 0
    
    // variable for loading feedback
    @State var isSaving : Bool = false
    
    //image
    @State var images: [UIImage] = []
    @State var photosPickerItems : [PhotosPickerItem]  = []
    
    // Optional image for Share Extension to provide
    @State var selectedImage: UIImage?

    init(showingSheet: Binding<Bool>, longitude: Double, latitude: Double, selectedImage: UIImage? = nil) {
        self._showingSheet = showingSheet
        self._selectedImage = State(initialValue: selectedImage)
        _viewModel = StateObject(wrappedValue: NewJournalViewModel(longitude: longitude, latitude: latitude))
    }
    
    var placeNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Place Name")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .trailing) {
                TextField("Enter place name", text: $viewModel.placeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusField, equals: .placeName)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(autofillBackgroundOpacity))
                            .allowsHitTesting(false)
                    )
                    .scaleEffect(placeNameScale)
                
                if !viewModel.placeName.isEmpty {
                    Button(action: { viewModel.placeName = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
        }
    }
    
    var addressField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Address")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .trailing) {
                TextField("Enter address", text: $viewModel.placeAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusField, equals: .placeAddress)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(autofillBackgroundOpacity))
                            .allowsHitTesting(false)
                    )
                    .scaleEffect(addressScale)
                
                if !viewModel.placeAddress.isEmpty {
                    Button(action: { viewModel.placeAddress = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
        }
    }
    
    public var body: some View {
        ZStack{
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Card
                        VStack(spacing: 16) {
                            HStack {
                                TextField("Journal title", text: $viewModel.journalTitle)
                                    .font(.title2.bold())
                                    .focused($focusField, equals: .title)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        viewModel.isFavourite.toggle()
                                    }
                                }) {
                                    Image(systemName: viewModel.isFavourite ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(viewModel.isFavourite ? .red : .gray)
                                        .scaleEffect(viewModel.isFavourite ? 1.1 : 1.0)
                                }
                                .padding(.trailing)
                            }
                            
                            DatePicker("Date", selection: $viewModel.journalDate, displayedComponents: [.date])
                                .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Journal Entry Card
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Journal Entry", systemImage: "pencil.line")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $viewModel.journalEntry)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        
                        // upload photo
                        VStack{
                            PhotosPicker(selection: $photosPickerItems){
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                    Text("Add Image")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            
                        }
                        
                        // Display selected photo thumbnails
                        if !images.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(images.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: images[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            // Delete icon overlay
                                            Button(action: {
                                                images.remove(at: index) // Remove image from array
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .offset(x: 5, y: -5) // Positioning the icon
                                            }
                                            .buttonStyle(PlainButtonStyle()) // Remove button tap animation
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }

                        // Location Card
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Location Details", systemImage: "mappin.circle.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            placeNameField
                            addressField
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Suggestions Card
                        if !viewModel.places.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("Nearby Places", systemImage: "location.circle.fill")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    if viewModel.places.count > 3 {
                                        Button("Show all") {
                                            viewModel.showSuggestionsSheet()
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    }
                                }
                                
                                if viewModel.isFetchingSuggestions {
                                    HStack {
                                        Text("Fetching suggestions")
                                        ProgressView()
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    ForEach(viewModel.places.prefix(3)) { place in
                                        PlaceRow(place: place)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                focusField = nil
                                                viewModel.autofillPlace(placeName: place.placeName, placeAddress: place.placeAddress)
                                                animateAutoFill()
                                            }
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Save Button
                        Button(action: {
                            isSaving = true
                            uploadImagesAndSaveJournal()
                            
                            
                            mapViewModel.tappedCoordinates = nil
                            
                            
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save Journal")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.validForm ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(!viewModel.validForm)
                        .padding(.horizontal)
                        .opacity(viewModel.validForm ? 1 : 0.7)
                    }
                    .padding()
                }
                
                .navigationTitle("New Journal")
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    viewModel.fetchNearbyPlaces()
                    mapViewModel.tappedCoordinates = nil
                    addSelectedImage()
                }
                // append selected images to images array
                .onChange(of: photosPickerItems){ _, _ in
                    Task{
                        
                        for item in photosPickerItems{
                            if let data = try? await item.loadTransferable(type: Data.self){
                                if let image = UIImage(data: data){
                                    
                                    images.append(image)
                                }
                            }
                        }
                        photosPickerItems.removeAll()
                        
                    }
                }
                .sheet(isPresented: $viewModel.isShowingSuggestionsSheet) {
                    PlaceListView(showSheet: $viewModel.isShowingSuggestionsSheet,
                                  placeName: $viewModel.placeName,
                                  placeAddress: $viewModel.placeAddress,
                                  places: viewModel.places)
                }
                .alert("Journal saved successfully!", isPresented: $viewModel.isJournalSaved) {
                    Button("OK") {
                        showingSheet = false
                    }
                }
            }
            // Show loading indicator
            if isSaving {
                LoadingOverlayView()
            }
        
    }
}
    
    // Upload images, populate imageReferences, then save the journal
    func uploadImagesAndSaveJournal() {
        guard !images.isEmpty else {
            saveJournalToFirestore()
            saveJournalSwiftData()
            isSaving = false
            viewModel.isJournalSaved = true
            print("Images is empty")
            return
        }
        
        var uploadedImagesCount = 0
        for image in images {
            viewModel.uploadImage(selectedImage: image) { success in
                if success {
                    uploadedImagesCount += 1
                    // Check if all images are uploaded
                    if uploadedImagesCount == images.count {
                        // Once all images are uploaded, save the journal to Firestore and Swift Data
                        saveJournalToFirestore()
                        saveJournalSwiftData()
                        isSaving = false
                        viewModel.isJournalSaved = true
                    }
                } else {
                    print("Failed to upload an image")
                }
            }
        }
    }
    
    func saveJournalToFirestore() {
         if let userId = authController.currentUser?.id {
             viewModel.saveJournalFirestore(userId: userId)
         }
     }
    
    
    func saveJournalSwiftData() {
        if let userId = authController.currentUser?.id {
            let journal = JournalSwiftData(
                journalTitle: viewModel.journalTitle,
                journalEntry: viewModel.journalEntry,
                date: viewModel.journalDate,
                placeName: viewModel.placeName,
                address: viewModel.placeAddress,
                latitude: viewModel.placeLatitude,
                longitude: viewModel.placeLongitude,
                userId: userId,
                imageReferences: viewModel.imageReferences,
                isFavourite: viewModel.isFavourite
            )
            context.insert(journal)
            
            do {
                try context.save()  // Ensure the data is saved
                print("Journal saved for: \(userId)")
            } catch {
                print("Failed to save journal: \(error)")
            }
            
            print("Journal saved for: \(userId)")
        }
        
    }

    
    func animateAutoFill() {
        // Reset any existing animations
        placeNameScale = 1.0
        addressScale = 1.0
        autofillBackgroundOpacity = 0
        
        // Sequence of animations
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            placeNameScale = 0.98
            addressScale = 0.98
            autofillBackgroundOpacity = 0.15
        }
        
        // Second phase - return to normal with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                placeNameScale = 1.0
                addressScale = 1.0
            }
        }
        
        // Final phase - fade out background
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                autofillBackgroundOpacity = 0
            }
        }
    }
    
    func addSelectedImage() {
        if (selectedImage == nil) {
            print("SelectedImage is NIL")
        }
        if let image = selectedImage {
            images.append(image)
            print("Successfully added selected image")
        } else {
            print("No selected image found")
        }
        print("Images list size is: \(images.count)")
    }
    
}


#Preview {
    NewJournalView(showingSheet: .constant(true), longitude: 0.0, latitude: 0.0)
}
