//
//  Debouncer.swift
//  Travel Journal App
//
//  Created by Byron Lester on 23/10/2024.
//

import Foundation

// Used to reduce frequency of API requests
class Debouncer : ObservableObject {
    private var workItem: DispatchWorkItem?
    private let queue = DispatchQueue.main // Use a specific queue for thread safety

    func debounce(delay: TimeInterval, action: @escaping () -> Void) {
        // Cancel the previous task if it exists
        workItem?.cancel()

        // Create a new DispatchWorkItem
        workItem = DispatchWorkItem { [weak self] in
            // Ensure `self` is still around when the action is executed
            guard self != nil else { return }
            action()
        }

        // Execute the new work item after the delay on the main queue
        queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}

// How to use debouncer

/*
    struct ContentView: View {
     @StateObject private var debouncer = Debouncer()
     @State private var searchText = ""

     var body: some View {
         TextField("Search", text: $searchText)
             .onChange(of: searchText) { newValue in
                 debouncer.debounce(delay: 0.5) {
                     print("Performing search for: \(newValue)")
                 }
             }
     }
    }

 */
