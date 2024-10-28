//
//  EditProfileViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 29/10/2024.
//

import Foundation

@MainActor
class EditProfileViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    
    func showNameEmail(name: String, email: String) {
        
        self.name = name
        self.email = email
    }
    
    func updateProfile(authController: AuthController) async -> Bool {

        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Implement your update logic here
            try await authController.updateProfile(newEmail: email, newName: name)
            alertMessage = "Profile updated successfully!"
            showingAlert = true
            return true
            
        } catch {
            alertMessage = "Failed to update profile: \(error.localizedDescription)"
            showingAlert = true
            return false
        }
    }
}
