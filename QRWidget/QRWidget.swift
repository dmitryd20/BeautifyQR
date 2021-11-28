//
//  QRWidget.swift
//  QRWidget
//
//  Created by Дмитрий Демьянов on 28.11.2021.
//

import WidgetKit
import SwiftUI


struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> QREntry {
        .demo
    }

    func getSnapshot(in context: Context, completion: @escaping (QREntry) -> ()) {
        completion(QREntry(date: .now, qrImage: StorageService().lastImage))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [QREntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date.now
        let lastImage = StorageService().lastImage
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            entries.append(QREntry(date: entryDate, qrImage: lastImage))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct QREntry: TimelineEntry {
    let date: Date
    let qrImage: UIImage?
}

extension QREntry {
    static var demo: QREntry {
        return .init(date: .now, qrImage: .init(named: "demo"))
    }
}

struct QRWidgetEntryView : View {
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        if let image = entry.qrImage {
            Image(uiImage: image)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(16)
            
        } else {
            Text("Нажмите, чтобы создать свой QR-код")
        }
        
    }
}

@main
struct QRWidget: Widget {
    let kind: String = "QRWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QRWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("QR Widget")
        .description("Виджет с QR-кодом")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct QRWidget_Previews: PreviewProvider {
    static var previews: some View {
        QRWidgetEntryView(entry: .demo)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
