//
//  Firestore Manager.swift
//  Advanced-iOS_AT2
//
//  Created by Byron Lester on 3/9/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

enum FirestoreCollection: String {
    case users = "users"
    case journals = "journals"
}

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    // Simple function that checks with FirebaseAuth if credentials match
    func authenticateUser(email:String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func isEmailUnique(email: String) async -> Bool {
        
        do {
            let emailQuerySnapshot = try await Firestore.firestore().collection(FirestoreCollection.users.rawValue).whereField("email", isEqualTo: email).getDocuments()
            
            if(emailQuerySnapshot.isEmpty) {
               return false
            }
        }
        catch {
            print("Error verifying email: \(error.localizedDescription)")
        }
        
        return true
    }
    
    // Creates a user in FirebaseAuth and Firestore Database
    func createUser(email: String, password: String, name: String) async {
        
        do {
            // Create user in FirebaseAuth
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user in Firestore database
            let user = User(id: authResult.user.uid, name: name, email: email)
            
            // Encode user
            let encodedUser = try Firestore.Encoder().encode(user)
            
            
            try await Firestore.firestore().collection(FirestoreCollection.users.rawValue).document(user.id).setData(encodedUser)
        }
        
        catch {
            print("Failed to create user: \(error.localizedDescription)")
        }
        
    }
    
    func fetchUser(uid: String) async -> DocumentSnapshot? {
        do {
            let snapshot = try await Firestore.firestore().collection(FirestoreCollection.users.rawValue).document(uid).getDocument()
            return snapshot
        }
        catch {
            print("Error retrieving snapshot")
            return nil
        }
    }
    
    
    // Generic function to add any Encodable object as subcollection to a user
    func addDocument<T: Encodable>(object: T, toCollection collection: String, forUserId uid: String) throws {
        let collectionRef = db.collection(FirestoreCollection.users.rawValue).document(uid).collection(collection)
        
        do {
            try collectionRef.addDocument(from: object) { error in
                if let error = error {
                    print("Error adding \(T.self) for \(uid) to Firestore: \(error.localizedDescription)")
                } else {
                    print("\(T.self) added successfully")
                }
            }
        } catch let error {
            print("Error adding \(T.self) for \(uid) to Firestore: \(error.localizedDescription)")
        }
    }
    
    
    // Generic function to retrieve any collection of documents from a user sub collection
    func fetchDocuments<T: Decodable>(uid: String, collectionName: String, as type: T.Type) async throws -> [T] {
        
        var documents: [T] = []
        
        let collectionRef = db.collection(FirestoreCollection.users.rawValue).document(uid).collection(collectionName)
                
        let querySnapshot = try await collectionRef.getDocuments()
        documents = try querySnapshot.documents.map { try $0.data(as: T.self) }
        
        return documents  // Returns empty array if error occurs
    }
    
    func deleteDocument(uid: String, collectionName: String, documentId: String) async throws {
        let documentRef = db.collection(FirestoreCollection.users.rawValue).document(uid).collection(collectionName).document(documentId)
        
        try await documentRef.delete()
    }
    
    func updateUserProfile(newEmail: String, newName: String) async throws {
        if let user = Auth.auth().currentUser {
            let userRef = db.collection(FirestoreCollection.users.rawValue).document(user.uid)
            
            try await userRef.updateData([
                "email": newEmail,
                "name": newName
            ])
        }
    }
    
}
