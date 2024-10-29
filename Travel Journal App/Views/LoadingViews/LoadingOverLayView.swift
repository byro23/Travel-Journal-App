//
//  LoadingOverLay.swift
//  Travel Journal App
//
//  Created by Ali Agha Jafari on 29/10/2024.
//

import SwiftUI


import SwiftUI

// Full-screen loading overlay view
struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5) // Full-screen dimmed background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Saving your journal...")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding(40)
            .background(Color.black.opacity(0.75))
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

