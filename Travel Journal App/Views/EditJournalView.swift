//
//  EditJournalView.swift
//  Travel Journal App
//
//  Created by Ali Agha Jafari on 29/10/2024.
//

import SwiftUI
import SwiftData

struct EditJournalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var journal: JournalSwiftData // Use @Bindable for SwiftData
    
    // State variable for loading indicator
    @State private var isUpdating: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Card
                        VStack(spacing: 16) {
                            HStack {
                                TextField("Journal Title", text: $journal.journalTitle)
                                    .font(.title2.bold())
//                                    .padding(.horizontal)
//                                    .background(Color(.systemGray6))
//                                    .cornerRadius(8)
                               
                            }
                            
                            DatePicker("Date", selection: $journal.date, displayedComponents: [.date, .hourAndMinute])
//                                .padding(.horizontal)
//                                .background(Color(.systemGray6))
//                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Journal Entry Card
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Journal Entry", systemImage: "pencil.line")
                                .font(.headline)
                                .foregroundColor(.primary)
                                
                            
                            TextEditor(text: $journal.journalEntry)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
//                                .padding([.leading, .trailing, .bottom])
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Update Button
                        Button(action: {
                            updateJournal()
                        }) {
                            HStack {
                                Spacer()
                                if isUpdating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Update Journal")
                                        .font(.headline)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(journal.journalTitle.isEmpty || journal.journalEntry.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(journal.journalTitle.isEmpty || journal.journalEntry.isEmpty || isUpdating)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding()
                }
                .navigationTitle("Edit Journal")
                .background(Color(.systemGroupedBackground))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            
            // Loading Overlay
            if isUpdating {
                LoadingOverlayViewUpdate()
            }
        }
    }
    
    // MARK: - Update Function
    
    private func updateJournal() {
        isUpdating = true
        // Simulate a network or database update delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                try context.save()
                isUpdating = false
                dismiss()
            } catch {
                print("Failed to update journal: \(error.localizedDescription)")
                isUpdating = false
                // Optionally, show an alert to the user
            }
        }
    }
}

struct LoadingOverlayViewUpdate: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressView("Updating...")
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 10)
        }
    }
}

