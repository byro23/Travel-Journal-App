//
//  HeaderView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        
        HStack {
            Image(systemName: "book.pages")
                .imageScale(.large)
                .foregroundStyle(.black)
            
            Text("My Travel Journal")
                .font(.title)
                .fontWeight(.semibold)
        }
        .padding()
    }
}

#Preview {
    HeaderView()
}
