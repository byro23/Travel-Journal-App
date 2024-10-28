//
//  Widget_Extension.swift
//  Widget-Extension
//
//  Created by Dylan Archer on 23/10/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imageUrl: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), imageUrl: URL(string: "https://example.com/image.jpg"))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()

        fetchRandomImageUrl { imageUrl in
            // Create entries with the fetched image URL
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, imageUrl: imageUrl)
                entries.append(entry)
            }

            // Pass the timeline back to the widget
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

    func fetchRandomImageUrl(completion: @escaping (URL?) -> ()) {
        
        let testImageUrl = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Altja_j%C3%B5gi_Lahemaal.jpg/800px-Altja_j%C3%B5gi_Lahemaal.jpg")
        print("Image URL: \(String(describing: testImageUrl))")
        completion(testImageUrl)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageUrl: URL?
}

struct Widget_ExtensionEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            if let imageUrl = entry.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray // Placeholder while image loads
                }
            } else {
                Color.gray // Fallback if no image URL is available
            }
            
            // Text overlay for the date
            VStack {
                Spacer()
                Text(entry.date, style: .date)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding([.leading, .bottom, .trailing], 8)
            }
        }
    }
}

struct Widget_Extension: Widget {
    let kind: String = "Widget_Extension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                Widget_ExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Widget_ExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Travel Journal Image")
        .description("Shows a random travel journal image with the date.")
    }
}

#Preview(as: .systemSmall) {
    Widget_Extension()
} timeline: {
    SimpleEntry(date: .now, imageUrl: URL(string: "https://example.com/image.jpg"))
}
