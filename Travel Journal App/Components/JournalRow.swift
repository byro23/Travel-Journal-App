//
//  JournalRow.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import SwiftUI

struct JournalRow: View {
    let journal: JournalSwiftData
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Date column
            VStack(alignment: .center) {
                Text(dateFormatter.string(from: journal.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)
            }
            .frame(width: 70)
            
            // Main content
            VStack(alignment: .leading, spacing: 4) {
                Text(journal.journalTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(journal.placeName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(journal.journalEntry)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                // Image indicators
                if !journal.imageReferences.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(.blue)
                        Text("\(journal.imageReferences.count) photos")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Right arrow indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Preview with multiple mock journals to show variety
struct JournalRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            // Original mock journal
            JournalRow(journal: JournalSwiftData.MOCK_JOURNAL)
            
            // Additional mock journal with images
            JournalRow(journal: JournalSwiftData(
                journalTitle: "Sydney Harbor Bridge Walk",
                journalEntry: "Amazing walk across the bridge with breathtaking views of the Opera House and harbor. The weather was perfect and we managed to catch the sunset.",
                date: Date().addingTimeInterval(-86400), // Yesterday
                placeName: "Sydney Harbor Bridge",
                address: "Sydney Harbor Bridge, NSW",
                latitude: -33.8523,
                longitude: 151.2108,
                userId: "",
                imageReferences: ["photo1", "photo2", "photo3"],
                isFavourite : false
            ))
            
            // Another variation
            JournalRow(journal: JournalSwiftData(
                journalTitle: "Manly Beach Surfing",
                journalEntry: "First time surfing! The waves were perfect for beginners.",
                date: Date().addingTimeInterval(-172800), // 2 days ago
                placeName: "Manly Beach",
                address: "Manly Beach, NSW",
                latitude: -33.7971,
                longitude: 151.2877,
                userId: "",
                imageReferences: ["photo1"],
                isFavourite: true
            ))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
