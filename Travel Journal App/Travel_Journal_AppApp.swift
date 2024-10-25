//
//  Travel_Journal_AppApp.swift
//  Travel Journal App
//
//  Created by Byron Lester on 16/10/2024.
//

import SwiftUI
import SwiftData

@main
struct Travel_Journal_AppApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var navigationController = NavigationController()
    @StateObject var authController = AuthController()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                UserView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
        .modelContainer(for: JournalSwiftData.self) // Stores journals using Swift Data
        .environmentObject(navigationController)
        .environmentObject(authController)
    }
}
