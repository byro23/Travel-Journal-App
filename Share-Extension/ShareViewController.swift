//
//  ShareViewController.swift
//  Share-Extension
//
//  Created by Dylan Archer on 19/10/2024.
//

import UIKit
import Social
import Photos
import UniformTypeIdentifiers
import FirebaseAuth
import FirebaseCore
import SwiftUI

class ShareViewController: SLComposeServiceViewController {
    
    @StateObject var mapViewModel = MapViewModel()
    let authController = AuthController()
    var loadingView: UIHostingController<LoadingView>?
    
    @State var selectedImage: UIImage?
    var selectedCoordinates: (latitude: Double, longitude: Double) = (1, 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()
        showLoadingView()
        
        // Get selected image
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
                return
            }
        
            // Check type identifier
            let imageDataType = UTType.image.identifier
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                
                // Load the item from itemProvider
                itemProvider.loadItem(forTypeIdentifier: imageDataType , options: nil) { (providedImage, error) in
                    if let error {
                        print("Error loading image: \(error)")
                        return
                    }
                    
                    if let image = providedImage as? UIImage {
                        self.selectedImage = image
                        self.extractLocationData(from: image)
                        print("Set selectedImage from loaded UIImage")
                    } else if let url = providedImage as? URL {
                        do {
                            print("Loading image from URL: \(url)")
                            if FileManager.default.fileExists(atPath: url.path) {
                                print("File exists at path: \(url.path)")
                            } else {
                                print("File does not exist at path: \(url.path)")
                            }

                            let imageData = try Data(contentsOf: url)
                            if let image = UIImage(data: imageData) {
                                self.selectedImage = image
                                self.extractLocationData(from: image)
                                print("Set selectedImage from loaded URl")
                            } else {
                                print("Could not create UIImage from data.")
                            }
                        } catch {
                            print("Error loading image from URL: \(error.localizedDescription)")
                        }
                    } else {
                        print("Provided item is not a UIImage or URL.")
                    }
                    
                    // Check selectedImage for nil after attempts to load
                    if self.selectedImage == nil {
                        print("Selected image is NIL after attempts to load.")
                    } else {
                        print("Selected image loaded successfully.")
                    }
                    
                    // Retrieve email and password
                    self.retrieveCredentialsFromSharedFile { [weak self] email, password in
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
                            
                            guard let currentUser = await self.authController.currentUser else {
                                DispatchQueue.main.async {
                                    self.loadingView?.view.removeFromSuperview()
                                    self.loadingView = nil
                                    self.presentErrorView()
                                }
                                print("No user returned after authentication with email: \(email)")
                                return
                            }
                            
                            if let image = await self.selectedImage {
                                print("Selected image is valid before passing to NewJournalView")
                            } else {
                                print("Selected image is NIL before passing to NewJournalView")
                            }
                            
                            DispatchQueue.main.async {
                                self.loadingView?.view.removeFromSuperview()
                                self.loadingView = nil
                                self.presentView(with: currentUser)
                            }
                        }
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
    
    private func presentView(with user: User) {
        let contentView = UIHostingController(rootView: NewJournalView(showingSheet: .constant(true), longitude: selectedCoordinates.longitude, latitude: selectedCoordinates.latitude, selectedImage: selectedImage)
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
    
    private func extractLocationData(from image: UIImage) {
            // Convert UIImage to PHAsset to get location data
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            
            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            guard let asset = fetchResult.firstObject else { return }
            
            // Check for location data
            if let location = asset.location {
                selectedCoordinates = (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                print("Extracted coordinates: \(selectedCoordinates)")
            } else {
                print("No location data found in the image.")
            }
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

