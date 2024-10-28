//
//  ShareViewController.swift
//  Share-Extension
//
//  Created by Dylan Archer on 19/10/2024.
//

import UIKit
import Social
import UniformTypeIdentifiers
import SwiftUI

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
            super.viewDidLoad()
        
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
                close()
                return
            }
        
                // Check type identifier
                let imageDataType = UTType.image.identifier
                if itemProvider.hasItemConformingToTypeIdentifier(imageDataType) {
                    
                    // Load the item from itemProvider
                    itemProvider.loadItem(forTypeIdentifier: imageDataType , options: nil) { (providedImage, error) in
                        if let error {
                            print("Error loading image: \(error)")
                            self.close()
                            return
                        }
                        
                        // Check if providedImage is a UIImage
                            if let image = providedImage as? UIImage {
                                // Display UIImage
                                DispatchQueue.main.async {
                                    let contentView = UIHostingController(rootView: ShareView(image: image))
                                    self.addChild(contentView)
                                    self.view.addSubview(contentView.view)
                                    self.setupConstraints(for: contentView)
                                }
                            }
                            // Check if providedImage is a file URL to the image
                            else if let url = providedImage as? URL, let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                                // Display image from URL
                                DispatchQueue.main.async {
                                    let contentView = UIHostingController(rootView: ShareView(image: image))
                                    self.addChild(contentView)
                                    self.view.addSubview(contentView.view)
                                    self.setupConstraints(for: contentView)
                                }
                            }
                            // Check if providedImage is NSData and convert to UIImage
                            else if let imageData = providedImage as? Data, let image = UIImage(data: imageData) {
                                // Display image from NSData
                                DispatchQueue.main.async {
                                    let contentView = UIHostingController(rootView: ShareView(image: image))
                                    self.addChild(contentView)
                                    self.view.addSubview(contentView.view)
                                    self.setupConstraints(for: contentView)
                                }
                            }
                            else {
                                self.close()
                                return
                            }
                    }
                } else {
                    close()
                    return
                }
                
                // Listens for ShareView to notify to close the view
                NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
                    DispatchQueue.main.async {
                        self.close()
                    }
                }
    }
       
    func setupConstraints(for contentView: UIHostingController<ShareView>) {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }

    
    // Close the Share Extension
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
