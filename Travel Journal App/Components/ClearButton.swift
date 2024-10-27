//
//  ClearButton.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

// MARK: - View
struct ClearButton: View { // Clear button to quickly clear textfield
    
    // MARK: - Properties
    @Binding var text: String
    
    // MARK: - Body
    var body: some View {
        if text.isEmpty == false {
            HStack {
                Spacer()
                Button {
                    text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                }
                .foregroundColor(.secondary)
            }
        } else {
            EmptyView()
        }
    }
}

// MARK: - Preview
#Preview {
    ClearButton(text: .constant("Test"))
}
