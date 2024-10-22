//
//  User.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    
}

extension User {
    static var Mock_User = User(id: UUID().uuidString, name: "Geoff", email: "test@gmail.com")
}

