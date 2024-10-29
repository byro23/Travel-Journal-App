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
import FirebaseCore
import SwiftUI

class ShareViewController: SLComposeServiceViewController {
    
    @StateObject var mapViewModel = MapViewModel()
    let authController = AuthController()
    var loadingView: UIHostingController<LoadingView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()
        showLoadingView()
        
        // Retrieve email and password
        retrieveCredentialsFromSharedFile { [weak self] email, password in
            guard let self = self, let email = email, let password = password else {
                print("No valid credentials found.")
                DispatchQueue.main.async {
                    self?.loadingView?.view.removeFromSuperview()
                    self?.loadingView = nil
                    self?.presentErrorView()
                }
                return
            }
            
            // Sign in and show view
            Task {
                await self.authController.signIn(email: email, password: password)
                
                guard let currentUser = self.authController.currentUser else {
                    DispatchQueue.main.async {
                        self.loadingView?.view.removeFromSuperview()
                        self.loadingView = nil
                        self.presentErrorView()
                    }
                    print("No user returned after authentication with email: \(email)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.loadingView?.view.removeFromSuperview()
                    self.loadingView = nil
                    self.presentShareView(with: currentUser)
                }
            }
        }
    }
    
    func retrieveCredentialsFromSharedFile(completion: @escaping (String?, String?) -> Void) {
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.UTS.Travel-Journal-App") {
            let emailFilePath = sharedContainerURL.appendingPathComponent("email.txt")
            let passwordFilePath = sharedContainerURL.appendingPathComponent("password.txt")
            
            do {
                let email = try String(contentsOf: emailFilePath, encoding: .utf8)
                let password = try String(contentsOf: passwordFilePath, encoding: .utf8)
                completion(email, password)
            } catch {
                print("Error reading credentials: \(error)")
                completion(nil, nil)
            }
        } else {
            print("Failed to access shared container.")
            completion(nil, nil)
        }
    }
    
    private func presentShareView(with user: User) {
            let contentView = UIHostingController(rootView: NewJournalView(showingSheet: .constant(true), longitude: 0.0, latitude: 0.0)
                .environmentObject(authController)
                .environmentObject(mapViewModel))
            self.addChild(contentView)
            self.view.addSubview(contentView.view)
            
            contentView.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                contentView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                contentView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                contentView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
            
            contentView.didMove(toParent: self)
        }
    
    private func presentErrorView() {
        let contentView = UIHostingController(rootView: ErrorView())
        self.addChild(contentView)
        contentView.view.frame = self.view.bounds
        self.view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
    }
    
    private func showLoadingView() {
        loadingView = UIHostingController(rootView: LoadingView())
        self.addChild(loadingView!)
        self.view.addSubview(loadingView!.view)
        
        // Set frame for loading view
        loadingView!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingView!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            loadingView!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingView!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        loadingView!.didMove(toParent: self)
    }

}

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

