//
//  NavigationController.swift
//  Advanced-iOS_AT2
//
//  Created by Byron Lester on 2/9/2024.
//

import Foundation
import SwiftUI

class NavigationController: ObservableObject {
    
    enum AppScreen: Hashable {
        case user
        case registration
    }
    
    enum Tab {
        case map
        case journal
    }
    
    // Helper to push a new screen
    func push(_ screen: AppScreen) {
        path.append(screen)
    }

    // Helper to pop the last screen
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    // Helper to reset the path (e.g., logout or return to home)
    func reset() {
        path = NavigationPath()
    }
    
    @Published var path = NavigationPath()
    @Published var currentTab = Tab.map
}

