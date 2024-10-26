//
//  FloatingTextField.swift
//  Travel Journal App
//
//  Created by Byron Lester on 26/10/2024.
//

import SwiftUI

struct FloatingTextField: View {
    let placeHolder: String
    @Binding var textInput: String
    @State private var isFocused: Bool = false
    
    @FocusState private var secureFieldFocused: Bool
    
    var isSecureField: Bool = false
    
    var body: some View {
        
        // Text Field
        if(!isSecureField) {
            VStack(alignment: .leading) {
                if(!textInput.isEmpty) {
                    Text(placeHolder)
                        .font(.caption)
                        .foregroundStyle(.cyan)
                        .transition(.scale)
                }
                TextField(placeHolder, text: $textInput) { focused in
                    withAnimation {
                        isFocused = focused
                    }
                }
                .textFieldStyle(.plain)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? Color.cyan : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isFocused ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                )
            }
            .animation(.default, value: textInput)
        }
        // Secure Field
        else {
            // Then in your view:
            VStack(alignment: .leading) {
                if(!textInput.isEmpty) {
                    Text(placeHolder)
                        .font(.caption)
                        .foregroundStyle(.cyan)
                        .transition(.scale)
                }
                SecureField(placeHolder, text: $textInput)
                    .focused($secureFieldFocused)
                    .onChange(of: secureFieldFocused) { oldValue, newValue in
                        withAnimation {
                            isFocused = newValue
                        }
                    }
                    .textFieldStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isFocused ? Color.cyan : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isFocused ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                    )
            }
            .animation(.default, value: textInput)
        }
    }
        
        
}

#Preview {
    FloatingTextField(placeHolder: "Place name", textInput: .constant("Test"))
}
