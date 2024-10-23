//
//  Travel_Journal_AppApp.swift
//  Travel Journal App
//
//  Created by Byron Lester on 16/10/2024.
//

import SwiftUI

@main
struct Travel_Journal_AppApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MapView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
