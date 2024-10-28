//
//  UserView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 22/10/2024.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var navigationController: NavigationController
    @StateObject var mapViewModel: MapViewModel = MapViewModel()
    
    var body: some View {
        // A TabView for navigating between different app sections.
        TabView(selection: $navigationController.currentTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(NavigationController.Tab.map)
                .environmentObject(mapViewModel)
            JournalsFirebaseView()
                .tabItem {
                    Label("Journals", systemImage: "book.fill")
                }
                .tag(NavigationController.Tab.journal)
                .environmentObject(mapViewModel)
            
        }
        .tabViewStyle(.automatic)
    }

}

#Preview {
    UserView(mapViewModel: MapViewModel())
        .environmentObject(MapViewModel())
}
