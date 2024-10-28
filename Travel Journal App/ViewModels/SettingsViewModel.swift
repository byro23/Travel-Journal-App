//
//  SettingsViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 28/10/2024.
//

import Foundation
import SwiftUI
import _PhotosUI_SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var showingImagePicker = false
    @Published var selectedItem: PhotosPickerItem?
    @Published var profileImage: Image?
    @Published var showingLogoutAlert = false
    @Published var showingEditProfile = false
    @Published var showingChangePassword = false
    
}
