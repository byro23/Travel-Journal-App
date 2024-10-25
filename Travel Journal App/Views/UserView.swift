//
//  UserView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var navigationController: NavigationController
    
    var body: some View {
        // A TabView for navigating between different app sections.
        TabView(selection: $navigationController.currentTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(NavigationController.Tab.map)
        }
    }
}

#Preview {
    UserView()
}
