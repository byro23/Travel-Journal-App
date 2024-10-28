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
    @StateObject var viewModel = ChangePasswordViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    SecureField("Current Password", text: $viewModel.currentPassword)
                        .textContentType(.password)
                } footer: {
                    Text("Enter your current password to verify your identity")
                }
                
                Section {
                    SecureField("New Password", text: $viewModel.newPassword)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm New Password", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                } footer: {
                    Text("Password must be at least 8 characters long")
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.changePassword(authController: authController)
                        }
                    } label: {
                        HStack {
                            Text("Update Password")
                            if viewModel.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
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
            .alert("Change Password", isPresented: $viewModel.showingAlert) {
                Button("OK") {
                    if viewModel.alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    ChangePasswordView()
}
