//
//  EditJournalViewModel.swift
//  Travel Journal App
//
//  Created by Ali Agha Jafari on 30/10/2024.
//
import Foundation
import MapKit
import PhotosUI
import FirebaseStorage
import SwiftUI


class EditJournalViewModel : ObservableObject{
    
    @Published var imageReferences: [String] = []

    
    
    
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
}
