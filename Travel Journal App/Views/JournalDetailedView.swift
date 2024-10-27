//
//  JournalDetailedView.swift
//  Travel Journal App
//
//  Created by Byron Lester on 27/10/2024.
//

import SwiftUI
import MapKit

struct JournalDetailedView: View {
    let journal: JournalSwiftData
    
    @State private var region: MKCoordinateRegion
    
    init(journal: JournalSwiftData) {
        self.journal = journal
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: journal.latitude,
                longitude: journal.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(journal.journalTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(journal.date.formatted(date: .long, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Images Section
                if !journal.imageReferences.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(journal.imageReferences, id: \.self) { imageRef in
                                AsyncImage(url: URL(string: imageRef)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .imageScale(.large)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 280, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Location Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text(journal.placeName)
                    }
                    
                    Text(journal.address)
                        .foregroundColor(.secondary)
                    
                    
                    
                    Map(coordinateRegion: $region, annotationItems: [journal]) { journal in
                        MapMarker(coordinate: CLLocationCoordinate2D(
                            latitude: journal.latitude,
                            longitude: journal.longitude
                        ))
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // Journal Entry Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Journal Entry")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(journal.journalEntry)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        JournalDetailedView(journal: JournalSwiftData.MOCK_JOURNAL)
    }
}
