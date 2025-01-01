//
//  AheadCalWidget.swift
//  AheadCalWidget
//
//  Created by Zhichao Feng on 2025/1/1.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        let entry = CalendarEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = CalendarEntry(date: currentDate)

        // 更新时间设置为每分钟
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
}

struct AheadCalWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        CalendarMonthView(date: entry.date, family: family)
    }
}

@main
struct AheadCalWidget: Widget {
    let kind: String = "AheadCalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AheadCalWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ahead Calendar")
        .description("Shows current month calendar")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
