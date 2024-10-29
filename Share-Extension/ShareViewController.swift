//
//  ShareViewController.swift
//  Share-Extension
//
//  Created by Dylan Archer on 19/10/2024.
//

import UIKit
import Social
import UniformTypeIdentifiers
import FirebaseAuth
import SwiftUI

class ShareViewController: SLComposeServiceViewController {
    
    let authController = AuthController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sign in user and load the view
        retrieveIDTokenFromSharedFile { [weak self] token in
            guard let self = self, let token = token else {
                print("No valid ID token found.")
                DispatchQueue.main.async {
                    self?.presentErrorView()
                }
                return
            }
            
            self.authController.signIn(with: token)
            
            guard let currentUser = authController.currentUser else {
                print("No user returned after authentication.")
                return
            }
            
            DispatchQueue.main.async {
                self.presentShareView(with: currentUser)
            }
        }
    }
    
    private func retrieveIDTokenFromSharedFile(completion: @escaping (String?) -> Void) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let tokenFilePath = documentsDirectory.appendingPathComponent("firebaseIDToken.txt")
            
            do {
                let token = try String(contentsOf: tokenFilePath, encoding: .utf8)
                completion(token)
            } catch {
                print("Error reading ID token: \(error)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    private func presentShareView(with user: User) {
        let contentView = UIHostingController(rootView: NewPlaceView(showingSheet: .constant(true), longitude: 0.0, latitude: 0.0).environmentObject(authController))
        self.addChild(contentView)
        self.view.addSubview(contentView.view)
    }
    
    private func presentErrorView() {
        let contentView = UIHostingController(rootView: ErrorView())
        self.addChild(contentView)
        contentView.view.frame = self.view.bounds
        self.view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
    }

}
