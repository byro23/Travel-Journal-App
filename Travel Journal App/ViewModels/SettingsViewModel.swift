//
//  SettingsViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 28/10/2024.
//

import SwiftUI
import PhotosUI

class SettingsViewModel: ObservableObject {
    @Published var profileImage: Image?
    @Published var selectedItem: PhotosPickerItem?
    @Published var showingImagePicker = false
    @Published var showingLogoutAlert = false
    @Published var showingEditProfile = false
    @Published var showingChangePassword = false
    @Published var isLoading = false
    
    func handleImageSelection() {
        
    }
}
