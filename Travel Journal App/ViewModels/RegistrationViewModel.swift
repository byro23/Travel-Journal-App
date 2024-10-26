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
}
