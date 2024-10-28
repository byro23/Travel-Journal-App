//
//  ChangePasswordViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 29/10/2024.
//

import Foundation

@MainActor
class ChangePasswordViewModel: ObservableObject {
    
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    var isValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    func changePassword(authController: AuthController) async {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await authController.changePassword(currentPassword: currentPassword,
                                                      newPassword: newPassword)
                alertMessage = "Password changed successfully!"
                showingAlert = true
            } catch AuthError.incorrectPassword {
                alertMessage = "Current password is incorrect. Please try again."
                showingAlert = true
            } catch AuthError.weakPassword {
                alertMessage = "New password is too weak. Please use at least 6 characters."
                showingAlert = true
            } catch {
                alertMessage = "Failed to change password: \(error.localizedDescription)"
                showingAlert = true
            }
        }
}
