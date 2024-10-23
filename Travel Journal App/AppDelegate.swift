//
//  AppDelegate.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import SwiftUI
import FirebaseCore
import GooglePlaces


class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let placesAPIValue = ProcessInfo.processInfo.environment["PLACES_API_KEY"]
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
      
      FirebaseApp.configure()
      GMSPlacesClient.provideAPIKey(placesAPIValue ?? "")

      return true
  }
}
