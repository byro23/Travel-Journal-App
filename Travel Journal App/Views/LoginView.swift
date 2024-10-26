//
//  LoginView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                
                FloatingTextField(placeHolder: "Email", textInput: $viewModel.email)
                    .padding()
                
                FloatingTextField(placeHolder: "Password", textInput: $viewModel.password, isSecureField: true)
                    .padding()
                
                AnimatedSignInButton {
                    
                }
                .padding()
                
                // Button to RegistrationView
                HStack {
                    Text("Haven't got an account?")
                        .foregroundStyle(.gray)
                    NavigationLink("Signup") {
                        RegistrationView()
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
