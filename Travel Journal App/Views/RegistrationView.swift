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
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                FloatingTextField(placeHolder: "Email", textInput: $viewModel.email)
                    .padding()
                
                FloatingTextField(placeHolder: "Name", textInput: $viewModel.name)
                    .padding()
                
                FloatingTextField(placeHolder: "Password", textInput: $viewModel.password)
                    .padding()
                
                FloatingTextField(placeHolder: "Confirm Password", textInput: $viewModel.confirmPassword)
                    .padding()
                
                AnimatedSignInButton {
                    Task {
                        await authController.signUp(email: viewModel.email, password: viewModel.password, name: viewModel.name)
                    }
                }
                .padding()
            }
            .navigationTitle("Registration")
            .alert("Email already exists. Please try again", isPresented: $authController.isEmailTaken) {
                Button("Ok", role: .cancel) {
                    authController.isEmailTaken = false
                }
            }
        }
    }
}

#Preview {
    RegistrationView()
}
