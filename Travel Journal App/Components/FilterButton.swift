//
//  FilterButton.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    init(
        title: String = "Filter",
        isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color(.systemGray4), lineWidth: 0.5)
                        .opacity(isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 8) {
            FilterButton(title: "All", isSelected: true) {}
            FilterButton(title: "Recent") {}
            FilterButton(title: "Favorites") {}
        }
        .padding()
        .background(Color(.systemBackground))
        
        // Dark mode preview
        HStack(spacing: 8) {
            FilterButton(title: "All", isSelected: true) {}
            FilterButton(title: "Recent") {}
            FilterButton(title: "Favorites") {}
        }
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
    }
}
