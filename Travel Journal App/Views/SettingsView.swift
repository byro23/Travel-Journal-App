//
//  SettingsView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 28/10/2024.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    
    var body: some View {
        List {
            // Profile Section
            Section {
                HStack(spacing: 16) {
                    // Profile Image
                    ZStack {
                        if let profileImage = viewModel.profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        // Camera icon overlay
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 26, y: 26)
                    }
                    .onTapGesture {
                        viewModel.showingImagePicker = true
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authController.currentUser?.name ?? "User Name")
                            .font(.headline)
                        Text(authController.currentUser?.email ?? "email@example.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Account Management Section
            Section("Account Management") {
                Button {
                    viewModel.showingEditProfile = true
                } label: {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                        Text("Edit Profile")
                    }
                }
                
                Button {
                    viewModel.showingChangePassword = true
                } label: {
                    HStack {
                        Image(systemName: "lock.rotation")
                        Text("Change Password")
                    }
                }
                
                Button(role: .destructive) {
                    viewModel.showingLogoutAlert = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log Out")
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .photosPicker(isPresented: $viewModel.showingImagePicker,
                     selection: $viewModel.selectedItem,
                     matching: .images)
        .onChange(of: viewModel.selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        viewModel.profileImage = Image(uiImage: uiImage)
                        // await saveProfileImage(data)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $viewModel.showingChangePassword) {
            ChangePasswordView()
        }
        .alert("Log Out", isPresented: $viewModel.showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                navigationController.reset()
                authController.signOut()
                navigationController.currentTab = .map
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthController())
        .environmentObject(NavigationController())
}
