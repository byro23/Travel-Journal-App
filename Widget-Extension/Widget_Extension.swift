//
//  Widget_Extension.swift
//  Widget-Extension
//
//  Created by Dylan Archer on 23/10/2024.
//

import WidgetKit
import SwiftUI
import UIKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage
    let title: String
}

struct Widget_ExtensionEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack {
            Image(uiImage: entry.image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100) // Adjust as needed
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(entry.title)
                .font(.headline)
                .padding([.top], 8)
        }
        .padding()
    }
}

struct Widget_Extension: Widget {
    let kind: String = "Widget_Extension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Widget_ExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Travel Journal")
        .description("Shows the latest journal entry.")
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let originalImage = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")!
        let resizedImage = resizeImage(originalImage, targetSize: CGSize(width: 500, height: 500))
        return SimpleEntry(date: Date(), image: resizedImage, title: "Journal Title")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let originalImage = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")!
        let resizedImage = resizeImage(originalImage, targetSize: CGSize(width: 500, height: 500))
        let entry = SimpleEntry(date: Date(), image: resizedImage, title: "Journal Title")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let originalImage = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")!
        let resizedImage = resizeImage(originalImage, targetSize: CGSize(width: 500, height: 500))
        let entry = SimpleEntry(date: Date(), image: resizedImage, title: "Journal Title")
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// Helper function to resize images to fit within the widget's allowed dimensions
func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let scaleFactor = min(widthRatio, heightRatio)
    
    let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

struct Widget_Extension_Previews: PreviewProvider {
    static var previews: some View {
        Widget_ExtensionEntryView(entry: SimpleEntry(date: Date(), image: UIImage(systemName: "photo")!, title: "Journal Title"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
