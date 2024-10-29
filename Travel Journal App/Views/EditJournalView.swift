//
//  EditJournalView.swift
//  Travel Journal App
//
//  Created by Ali Agha Jafari on 29/10/2024.
//

import SwiftUI
import SwiftData
import PhotosUI
import FirebaseStorage

struct EditJournalView: View {
    
    @StateObject var viewModel: EditJournalViewModel

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var journal: JournalSwiftData // Use @Bindable for SwiftData
    
    // State variable for loading indicator
    @State private var isUpdating: Bool = false
    
    // To store selected UIImage instances
    @State private var images: [UIImage] = []
    
    // To store selected PhotosPickerItem instances
    @State private var photosPickerItems: [PhotosPickerItem] = []
    
//    // store images that is removed from storage
//    @State private var selectedImages: [UIImage] = []

    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Card
                        VStack(spacing: 16) {
                            HStack {
                                TextField("Journal Title", text: $journal.journalTitle)
                                    .font(.title2.bold())
                            }
                            DatePicker("Date", selection: $journal.date, displayedComponents: [.date, .hourAndMinute])

                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // button for adding photos
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
                        // show the images from journal.references array
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
                                                let image = images[index]
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
                        
                        // Journal Entry Card
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Journal Entry", systemImage: "pencil.line")
                                .font(.headline)
                                .foregroundColor(.primary)
                                
                            
                            TextEditor(text: $journal.journalEntry)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
//                                .padding([.leading, .trailing, .bottom])
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Update Button
                        Button(action: {
                            
                            uploadImagesAndSaveJournal()
                            
                            
                        }) {
                            HStack {
                                Spacer()
                                if isUpdating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Update Journal")
                                        .font(.headline)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(journal.journalTitle.isEmpty || journal.journalEntry.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(journal.journalTitle.isEmpty || journal.journalEntry.isEmpty || isUpdating)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding()
                }
                .navigationTitle("Edit Journal")
                .background(Color(.systemGroupedBackground))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .onAppear(){
                    fetchImages()
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
            }
            
            // Loading Overlay
            if isUpdating {
                LoadingOverlayViewUpdate()
            }
        }
    }
    
    
    /// update journal
    private func updateJournal() {
        journal.imageReferences = viewModel.imageReferences
        
        isUpdating = true
        // Simulate a network or database update delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                try context.save()
                isUpdating = false
                dismiss()
            } catch {
                print("Failed to update journal: \(error.localizedDescription)")
                isUpdating = false
                // Optionally, show an alert to the user
            }
        }
    }
    // Upload images, populate imageReferences, then save the journal
    func uploadImagesAndSaveJournal() {
        guard !images.isEmpty else {
           
            updateJournal()
//            isSaving = false
//            viewModel.isJournalSaved = true
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
//                        saveJournalToFirestore()
                        updateJournal()
//                        isSaving = false
//                        viewModel.isJournalSaved = true
                    }
                } else {
                    print("Failed to upload an image")
                }
            }
        }
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
            print("Images loaded: \(self.images.count)")
        }
    }
}



struct LoadingOverlayViewUpdate: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressView("Updating...")
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 10)
        }
    }
}

