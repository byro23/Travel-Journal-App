//
//  RegistrationViewModel.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var name = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var navigateToHome: Bool = false
    @Published var networkError: Bool = false
    
    var passwordsMatch: Bool {
        (!password.isEmpty || !confirmPassword.isEmpty) && password == confirmPassword
    }
    
    var validEmail: Bool {
        email.contains("@") && email.contains(".com")
    }
    
    var validName: Bool {
        !name.isEmpty
    }
    
    var validPassword: Bool {
        !password.isEmpty && password.count >= 8
    }
    
    var validForm: Bool {
        passwordsMatch && validEmail && validName && validPassword
    }
}
