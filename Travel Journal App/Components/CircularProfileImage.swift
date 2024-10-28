//
//  CircularProfileImage.swift
//  Travel Journal App
//
//  Created by Byron Lester on 28/10/2024.
//

import SwiftUI

struct CircularProfileImage: View {
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 80, height: 80)
            .foregroundColor(Color(.systemGray4))
        }
}

#Preview {
    CircularProfileImage()
}
