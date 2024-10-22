//
//  MapView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    var body: some View {
        
        VStack{
            HeaderView()
            
            Map()
        }
        
        
        
    }
}

#Preview {
    MapView()
}
