//
//  AnimatedSignInButton.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import SwiftUI

struct AnimatedSignInButton: View {
    @State private var isPressed = false
    @State private var isLoading = false
    let action: () async -> Void
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            // Simulate button press release
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            // Show loading state and perform action
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .transition(.scale.combined(with: .opacity))
                }
                
                Text("Sign In")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cyan)
                    .shadow(color: Color.cyan.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        AnimatedSignInButton {
            // Simulate an async action
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }
        .padding()
    }
}
