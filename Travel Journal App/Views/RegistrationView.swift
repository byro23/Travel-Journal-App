//
//  RegistrationView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject var viewModel = RegistrationViewModel()
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    
    var body: some View {
        VStack(alignment: .leading) {
            // Email Field
                
            HStack {
               
                ZStack {
                    FloatingTextField(placeHolder: "Email", textInput: $viewModel.email)
                        .padding()
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)
                    
                    ClearButton(text: $viewModel.email)
                        .opacity(viewModel.email.count > 3 ? 1 : 0)
                        .offset(x: viewModel.email.count > 3 ? -20 : 0, y: 10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.email.count > 3)
                }
                
                
            }
                
                
            
            // Name Field
            ZStack {
                FloatingTextField(placeHolder: "Name", textInput: $viewModel.name)
                    .padding()
                    .autocorrectionDisabled()
                    .textContentType(.name)
                
                ClearButton(text: $viewModel.name)
                    .opacity(viewModel.name.count > 3 ? 1 : 0)
                    .offset(x: viewModel.name.count > 3 ? -20 : 0, y: 10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.name.count > 3)
            }
            
            // Password Field with Requirements
            VStack(alignment: .leading, spacing: 4) {
                ZStack {
                    FloatingTextField(placeHolder: "Password", textInput: $viewModel.password, isSecureField: true)
                        .padding()
                        .textContentType(.password)
                    
                    ClearButton(text: $viewModel.password)
                        .opacity(viewModel.password.count > 3 ? 1 : 0)
                        .offset(x: viewModel.password.count > 3 ? -20 : 0, y: 10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.password.count > 3)
                }
                
                // Password Requirements Indicator
                PasswordRequirementView(password: viewModel.password)
                    .padding(.horizontal)
            }
            
            // Confirm Password Field
            ZStack {
                FloatingTextField(placeHolder: "Confirm Password", textInput: $viewModel.confirmPassword, isSecureField: true)
                    .padding()
                    .textContentType(.password)
                
                ClearButton(text: $viewModel.confirmPassword)
                    .opacity(viewModel.confirmPassword.count > 3 ? 1 : 0)
                    .offset(x: viewModel.confirmPassword.count > 3 ? -20 : 0, y: 10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.confirmPassword.count > 3)
            }
            
            AnimatedButton(buttonText: "Register now") {
                await authController.signUp(email: viewModel.email, password: viewModel.password, name: viewModel.name)
                
                if(authController.authenticationState == .authenticated) {
                    viewModel.navigateToHome = true
                    viewModel.resetFields()
                }
                else if(authController.isEmailTaken == false && authController.authenticationState == .unauthenticated) {
                    viewModel.networkError = true
                }
            }
            .disabled(!viewModel.validForm)
            .opacity(viewModel.validForm ? 1.0 : 0.5)
            .padding()
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Registration")
        .alert("Email already exists. Please try again", isPresented: $authController.isEmailTaken) {
            Button("Understood", role: .cancel) {
                authController.isEmailTaken = false
            }
        }
        .alert("Network error occurred. Please try again.", isPresented: $viewModel.networkError) {
            Button("Understood", role: .cancel) {
                viewModel.networkError = false
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToHome) {
            UserView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct PasswordRequirementView: View {
    let password: String
    
    private var isLengthValid: Bool {
        password.count >= 6
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isLengthValid ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            Text("At least 6 characters")
                .font(.caption)
                .foregroundColor(isLengthValid ? .green : .secondary)
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: isLengthValid)
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthController())
}
