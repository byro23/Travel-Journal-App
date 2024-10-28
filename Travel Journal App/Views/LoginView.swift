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
            
            ZStack {
                FloatingTextField(placeHolder: "Email", textInput: $viewModel.email)
                    .padding()
                    .textInputAutocapitalization(.never)
                    
                ClearButton(text: $viewModel.email)
                    .padding()
                    .padding(.trailing, 10)
                    .padding(.top, 18)
                    .opacity(viewModel.email.count > 3 ? 1 : 0)
                    .offset(x: viewModel.email.count > 3 ? 0 : 20)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.email.count > 3)
                
            }
            
            ZStack {
                FloatingTextField(placeHolder: "Password", textInput: $viewModel.password, isSecureField: true)
                    .padding()
                
                ClearButton(text: $viewModel.password)
                    .padding()
                    .padding(.trailing, 10)
                    .padding(.top, 18)
                    .opacity(viewModel.email.count > 3 ? 1 : 0)
                    .offset(x: viewModel.email.count > 3 ? 0 : 20)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.email.count > 3)
            }
            
            AnimatedButton(buttonText: "Login") {
                await authController.signIn(email: viewModel.email, password: viewModel.password)
                
                if(authController.authenticationState == .authenticated) {
                    navigationController.push(.user)
                    viewModel.resetFields()
                    
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
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
        .alert("Invalid credentials. Try again.", isPresented: $viewModel.incorrectCredentials) {
            Button("Ok", role: .cancel) {
                viewModel.incorrectCredentials = false
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthController())
}
