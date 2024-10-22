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

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    
    func authenticateUser(email:String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    
    func createUser(email: String, password: String, name: String) async throws -> Bool {
        
        do {
            let emailQuerySnapshot = try await Firestore.firestore().collection("Users").whereField("email", isEqualTo: email).getDocuments()
            
            if(!emailQuerySnapshot.isEmpty) {
                print("Email already exists")
                return false
            }
            
            
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            let user = User(id: authResult.user.uid, name: name, email: email)
            
            let encodedUser = try Firestore.Encoder().encode(user)
            
            
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            return true
        }
        
        catch {
            print("Failed to create user")
            return false
        }
        
    }
    
    func fetchUser(uid: String) async -> DocumentSnapshot? {
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            return snapshot
        }
        catch {
            print("Error retrieving snapshot")
            return nil
        }
    }
    
    
    // Generic function to add any Encodable object as subcollection to a user
    func addDocument<T: Encodable>(object: T, toCollection collection: String, forUser uid: String) throws {
        let collectionRef = db.collection("users").document(uid).collection(collection)
        
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
        
        let collectionRef = db.collection("users").document(uid).collection(collectionName)
                
        let querySnapshot = try await collectionRef.getDocuments()
        documents = try querySnapshot.documents.map { try $0.data(as: T.self) }
        
        return documents  // Returns empty array if error occurs
    }
    
    func deleteDocument(uid: String, collectionName: String, documentId: String) async throws {
        let documentRef = db.collection("users").document(uid).collection(collectionName).document(documentId)
        
        try await documentRef.delete()
    }
    
}
