//
//  LoginView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    
    var body: some View {
        VStack {
            HeaderView()
            
            FloatingTextField(placeHolder: "Email", textInput: $viewModel.email)
                .padding()
                .textInputAutocapitalization(.never)
            
            FloatingTextField(placeHolder: "Password", textInput: $viewModel.password, isSecureField: true)
                .padding()
            
            AnimatedButton(buttonText: "Login") {
                await authController.signIn(email: viewModel.email, password: viewModel.password)
                
                if(authController.authenticationState == .authenticated) {
                    navigationController.push(.user)
                }
                else {
                    viewModel.incorrectCredentials = true
                }
            }
            .disabled(!viewModel.validForm || authController.authenticationState == .authenticated)
            .opacity(viewModel.validForm ? 1: 0.7)
            .padding()
            
            // Button to RegistrationView
            HStack {
                Text("Haven't got an account?")
                    .foregroundStyle(.gray)
                Button {
                    navigationController.push(.registration)
                } label: {
                    Text("Signup")
                        .foregroundStyle(.cyan)
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthController())
}
