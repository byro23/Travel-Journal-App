//
//  AuthController.swift
//  Travel Journal App
//
//  Created by Byron Lester on 19/10/2024.
//

import Foundation
import Firebase
import FirebaseAuth

// Used to track the various authentication state changes that occur in a user session
enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

// MARK: - AuthController
@MainActor
class AuthController: ObservableObject { // This class is used to manage the user session
    //MARK: - Properties
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var isEmailTaken: Bool = false
    
    // MARK: - Functions
    
    // Authenticates the user
    func signIn(email: String, password: String) async {
        do {
            authenticationState = .authenticating
            try await FirebaseManager.shared.authenticateUser(email: email, password: password)
            print("User authenticated.")
            await fetchUser()
            authenticationState = .authenticated
        }
        catch {
            authenticationState = .unauthenticated
            print("Failed to login user.")
        }
        
        
    }
    
    // Create an account and authenticate the user
    func signUp(email: String, password: String, name: String) async {
        authenticationState = .authenticating
        
        // Check if email is unique
        isEmailTaken = await FirebaseManager.shared.isEmailUnique(email: email)
        
        // Force unwrapped as IsEmailUnique function has to return true or false
        if(isEmailTaken == false) {
            await FirebaseManager.shared.createUser(email: email, password: password, name: name)
            
            authenticationState = .authenticated
        }
        else {
            authenticationState = .unauthenticated
        }
    }
    
    // Fetches authenticated user from Firestore Db
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        // Retrieve user from Db
        guard let snapshot = await FirebaseManager.shared.fetchUser(uid: uid) else {
            print("Snapshot is nil")
            return
        }
        
        // Decode user
        do {
            self.currentUser = try snapshot.data(as: User.self)
        }
        catch {
            print("Error decoding user")
            print(error)
        }
    }
    
    // Sign the user out (deauthenciate)
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            authenticationState = .unauthenticated
        }
        catch {
            print("Error signing user out: \(error)")
        }
    }
    
    
}
