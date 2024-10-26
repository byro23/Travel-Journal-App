//
//  LoginViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    var validEmail: Bool {
        email.isEmpty == false && email.contains("@") && email.contains(".com")
    }
    
    var validPassword: Bool {
        password.count > 6
    }
    
    var validForm: Bool {
        validEmail && validPassword
    }
}
