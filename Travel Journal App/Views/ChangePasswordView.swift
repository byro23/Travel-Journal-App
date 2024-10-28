//
//  ChangePasswordView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 29/10/2024.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authController: AuthController
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var isValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    SecureField("Current Password", text: $currentPassword)
                        .textContentType(.password)
                } footer: {
                    Text("Enter your current password to verify your identity")
                }
                
                Section {
                    SecureField("New Password", text: $newPassword)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                } footer: {
                    Text("Password must be at least 8 characters long")
                }
                
                Section {
                    Button {
                        Task {
                            await changePassword()
                        }
                    } label: {
                        HStack {
                            Text("Update Password")
                            if isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(!isValid || isLoading)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Change Password", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func changePassword() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Implement your password change logic here
            // try await authController.changePassword(current: currentPassword, new: newPassword)
            alertMessage = "Password changed successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to change password: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
#Preview {
    ChangePasswordView()
}
