//
//  ContentView.swift
//  AheadCal
//
//  Created by Zhichao Feng on 2024/12/29.
//

import AheadCalShared
import SwiftUI
import WidgetKit

struct PlainMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
    }
}

struct ContentView: View {
    @State private var currentDate = Date()
    @State private var monthOffset = 0
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var displayDate: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    var body: some View {
        VStack(spacing: 15) {
            // Header row
            HStack {
                Spacer()

                Text("Ahead Cal")
                    .font(.system(size: 14, weight: .medium))

                Menu {
                    Button("Exit") {
                        NSApplication.shared.terminate(nil)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .menuStyle(PlainMenuStyle())
                .buttonStyle(.plain)
                .frame(width: 14, height: 14)

                Spacer()
            }
            .frame(maxWidth: .infinity)

            // Navigation row
            HStack {
                Button(action: { monthOffset -= 1 }) {
                    Image(systemName: "chevron.left.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    monthOffset = 0
                    currentDate = Date()
                }) {
                    Text("Today")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: { monthOffset += 1 }) {
                    Image(systemName: "chevron.right.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Calendar views
            VStack(spacing: 0) {
                CalendarMonthView(date: displayDate)
                CalendarMonthView(
                    date: Calendar.current.date(byAdding: .month, value: 1, to: displayDate)
                        ?? displayDate)
            }
        }
        .padding(10)
        .background(.background)
        .frame(width: 260)
        .onReceive(timer) { _ in
            currentDate = Date()
        }
        .background(ScrollViewerHelper(monthOffset: $monthOffset))
    }
}

struct CalendarMonthView: View {
    let date: Date
    private let calendar = Calendar.current

    private var days: [Date?] {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offsetDays = firstWeekday - 1

        return (0..<42).map { day in
            let calculatedDate = calendar.date(
                byAdding: .day, value: day - offsetDays, to: startOfMonth)
            if let date = calculatedDate, isCurrentMonth(date) {
                return date
            }
            return nil
        }
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: self.date, toGranularity: .month)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            let month = date.formatted(.dateTime.month(.abbreviated))
            let year = String(Calendar.current.component(.year, from: date))

            Text("\(month) \(year)")
                .font(.system(size: 14, weight: .medium))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        let isToday = calendar.isDateInToday(date)
                        let isWeekend = calendar.isDateInWeekend(date)
                        let isHoliday = HolidayStorage.shared.isHoliday(date)
                        let isWorkday = HolidayStorage.shared.isWorkday(date)

                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 14))
                            .frame(width: 24, height: 24)
                            .foregroundStyle(
                                isToday
                                    ? .white
                                    : (isHoliday || (isWeekend && !isWorkday) ? .red : .primary)
                            )
                            .background(
                                Circle()
                                    .fill(
                                        isToday
                                            ? (isHoliday || (isWeekend && !isWorkday)
                                                ? Color.red.opacity(0.8) : .blue) : .clear
                                    )
                                    .frame(width: 24, height: 24)
                            )
                    } else {
                        Text("")
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

struct ScrollViewerHelper: NSViewRepresentable {
    @Binding var monthOffset: Int

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            if event.deltaY > 0 {
                monthOffset -= 1
            } else if event.deltaY < 0 {
                monthOffset += 1
            }
            return event
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
