//
//  EditProfileView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 29/10/2024.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authController: AuthController
    
    @StateObject var viewModel = EditProfileViewModel()
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $viewModel.name)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                    
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Button {
                        Task {
                            let isSuccess = await viewModel.updateProfile(authController: authController)
                            
                            if isSuccess {
                                authController.currentUser?.email = viewModel.email
                                authController.currentUser?.name = viewModel.name
                            }
                        }
                    } label: {
                        HStack {
                            Text("Save Changes")
                            if viewModel.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Update Profile", isPresented: $viewModel.showingAlert) {
                Button("OK") {
                    if viewModel.alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
        .onAppear {
            viewModel.email = authController.currentUser?.email ?? "Preview mode"
            viewModel.name = authController.currentUser?.name ?? "Preview mode"
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthController())
}


