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
    case incorrect
}

enum AuthError: LocalizedError {
    case userNotFound
    case incorrectPassword
    case weakPassword
    case emailVerificationRequired
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found. Please sign in again."
        case .incorrectPassword:
            return "Current password is incorrect"
        case .weakPassword:
            return "New password is too weak. Please use at least 6 characters"
        case .emailVerificationRequired:
            return "Please verify your email address"
        case .unknownError(let error):
            return error.localizedDescription
        }
    }
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
            
            // Save the ID token to a shared file
            if let idToken = try await Auth.auth().currentUser?.getIDToken() {
                saveIDTokenToSharedFile(token: idToken)
            }
        }
        catch {
            authenticationState = .unauthenticated
            print("Failed to login user.")
        }
        
    }
    
    // Autehtictates the user using token
    func signIn(with token: String) {
        Auth.auth().signIn(withCustomToken: token) { [weak self] (authResult, error) in
            if let error = error {
                print("Error signing in with token: \(error)")
                return
            }
            
            // If authResult is successful, access the Firebase user
            if let firebaseUser = authResult?.user {
                // Map Firebase User to AppUser
                let userId = firebaseUser.uid
                let email = firebaseUser.email ?? ""
                self?.currentUser = User(id: userId, name: firebaseUser.displayName ?? "", email: email)
                print("Authenticated user ID: \(firebaseUser.uid)")
            }
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
            
            await signIn(email: email, password: password)
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
            
            // Remove ID token file
            removeIDTokenFile()
        }
        catch {
            print("Error signing user out: \(error)")
        }
    }
    
    func updateProfile(newEmail: String, newName: String) async throws {
        try await FirebaseManager.shared.updateUserProfile(newEmail: newEmail, newName: newName)
    }
    
    private func saveIDTokenToSharedFile(token: String) {
        // Use the main app's documents directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let tokenFilePath = documentsDirectory.appendingPathComponent("firebaseIDToken.txt")
            do {
                try token.write(to: tokenFilePath, atomically: true, encoding: .utf8)
            } catch {
                print("Error saving ID token: \(error)")
            }
        }
    }
    
    private func removeIDTokenFile() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let tokenFilePath = documentsDirectory.appendingPathComponent("firebaseIDToken.txt")
            do {
                try FileManager.default.removeItem(at: tokenFilePath)
            } catch {
                print("Error removing ID token file: \(error)")
            }
        }
    }
    
}

extension AuthController {
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            throw AuthError.userNotFound
        }
        
        // First, re-authenticate the user with their current password
        let credential = EmailAuthProvider.credential(withEmail: email,
                                                    password: currentPassword)
        
        do {
            // Re-authenticate
            try await user.reauthenticate(with: credential)
            
            // If re-authentication successful, update password
            try await user.updatePassword(to: newPassword)
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.wrongPassword.rawValue:
                throw AuthError.incorrectPassword
            case AuthErrorCode.weakPassword.rawValue:
                throw AuthError.weakPassword
            default:
                throw AuthError.unknownError(error)
            }
        }
    }
}
