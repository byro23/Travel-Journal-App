//
//  ShareView.swift
//  Share-Extension
//
//  Created by Dylan Archer on 19/10/2024.
//

import SwiftUI

struct ShareView: View {
        
        var body: some View {
            NavigationStack{
                VStack(spacing: 20){
                    if let imageData = image.pngData(),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text("Unable to load image")
                    }
                    
                    TextField("Journal", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        // TODO: save image to journal
                        close()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Share Extension")
                .toolbar {
                    Button("Cancel") {
                        close()
                    }
                }
            }
        }
    
    // Notifies ShareViewController to close the view
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}


