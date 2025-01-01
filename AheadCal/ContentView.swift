//
//  ContentView.swift
//  AheadCal
//
//  Created by Zhichao Feng on 2024/12/29.
//

import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date()
    @State private var monthOffset = 0
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var displayDate: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: { monthOffset -= 1 }) {
                    Image(systemName: "chevron.left")
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
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            VStack(spacing: 20) {
                CalendarMonthView(date: displayDate)
                CalendarMonthView(date: Calendar.current.date(byAdding: .month, value: 1, to: displayDate) ?? displayDate)
            }
        }
        .padding(10)
        .background(.background)
        .frame(width: 240)
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
            let calculatedDate = calendar.date(byAdding: .day, value: day - offsetDays, to: startOfMonth)
            if let date = calculatedDate, isCurrentMonth(date) {
                return date
            }
            return nil
        }
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: self.date, toGranularity: .month)
    }

    private func isHoliday(_ date: Date) -> Bool {
        let components = calendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day else { return false }

        // 2025年节假日
        let holidays: [(month: Int, day: Int)] = [
            (1, 1),  // 元旦
            (1, 28), // 春节
            (1, 29),
            (1, 30),
            (1, 31),
            (2, 1),
            (2, 2),
            (2, 3),
            (2, 4),
            (4, 4), // 清明节
            (4, 5),
            (4, 6),
            (5, 1), // 劳动节
            (5, 2),
            (5, 3),
            (5, 4),
            (5, 5),
            (5, 31), // 端午节
            (6, 1),
            (6, 2),
            (10, 1), // 国庆中秋节
            (10, 2),
            (10, 3),
            (10, 4),
            (10, 5),
            (10, 6),
            (10, 7),
            (10, 8),
        ]

        return holidays.contains { $0.month == month && $0.day == day }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
                .foregroundStyle(.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        let isHolidayDate = calendar.isDateInWeekend(date) || isHoliday(date)
                        let isToday = calendar.isDateInToday(date)

                        Text("\(calendar.component(.day, from: date))")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(isToday ? .white : (isHolidayDate ? .red : .primary))
                            .background(
                                Circle()
                                    .fill(isToday ? (isHolidayDate ? Color.red.opacity(0.8) : .blue) : .clear)
                                    .frame(width: 24, height: 24)
                            )
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
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
