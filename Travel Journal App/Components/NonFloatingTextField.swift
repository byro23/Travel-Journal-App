//
//  NonFloatingTextField.swift
//  Travel Journal App
//
//  Created by Byron Lester on 28/10/2024.
//

import SwiftUI

struct NonFloatingTextField: View {
    let placeHolder: String
    @Binding var textInput: String
    @State private var isFocused: Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
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
}

#Preview {
    NonFloatingTextField(placeHolder: "Test", textInput: .constant("Woo"))
}
