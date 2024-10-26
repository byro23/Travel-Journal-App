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
            ZStack {
                FloatingTextField(placeHolder: "Email", textInput: $viewModel.email)
                    .padding()
                    .textInputAutocapitalization(.never)
                
                if(viewModel.email.count > 3) {
                    ClearButton(text: $viewModel.email)
                        .padding(.trailing, 22)
                        .padding(.top, 18)
                }
            }
            
            ZStack {
                FloatingTextField(placeHolder: "Name", textInput: $viewModel.name)
                    .padding()
                
                if(viewModel.name.count > 3) {
                    ClearButton(text: $viewModel.name)
                        .padding(.trailing, 22)
                        .padding(.top, 18)
                }
                
            }
            
            ZStack {
                FloatingTextField(placeHolder: "Password", textInput: $viewModel.password, isSecureField: true)
                    .padding()
                
                if(viewModel.password.count > 3) {
                    ClearButton(text: $viewModel.password)
                        .padding(.trailing, 22)
                        .padding(.top, 18)
                }
            }
            
            ZStack {
                FloatingTextField(placeHolder: "Confirm Password", textInput: $viewModel.confirmPassword, isSecureField: true)
                    .padding()
                
                if(viewModel.confirmPassword.count > 3) {
                    ClearButton(text: $viewModel.confirmPassword)
                        .padding(.trailing, 22)
                        .padding(.top, 18)
                }
                
            }
            
            AnimatedSignInButton {
                await authController.signUp(email: viewModel.email, password: viewModel.password, name: viewModel.name)
                
                if(authController.authenticationState == .authenticated) {
                    viewModel.navigateToHome = true
                    viewModel.resetFields()
                    navigationController.path.removeLast()
                }
                // Network error case
                else if(authController.isEmailTaken == false && authController.authenticationState == .unauthenticated) {
                    viewModel.networkError = true
                }
            }
            .disabled(!viewModel.validForm)
            .opacity(viewModel.validForm ? 1.0 : 0.5)
            .padding()
        }
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

#Preview {
    RegistrationView()
        .environmentObject(AuthController())
}
