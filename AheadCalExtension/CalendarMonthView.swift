import AheadCalShared
import SwiftUI
import WidgetKit

struct CalendarMonthView: View {
    let date: Date
    let family: WidgetFamily
    private let calendar = Calendar.current

    var body: some View {
        if family == .systemMedium {
            HStack(alignment: .top, spacing: 16) {
                monthView(for: date)
                monthView(for: calendar.date(byAdding: .month, value: 1, to: date) ?? date)
            }
        } else if family == .systemLarge {
            // render 4 months in a grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(0..<4) { index in
                    monthView(for: calendar.date(byAdding: .month, value: index, to: date) ?? date)
                }
            }
        } else {
            monthView(for: date)
        }
    }

    private func monthView(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date.formatted(.dateTime.month(.wide).year()))
                .font(.caption)
                .foregroundStyle(.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(Array(days(for: date).enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        let isToday = calendar.isDateInToday(date)
                        let isWeekend = calendar.isDateInWeekend(date)
                        let isHoliday = HolidayStorage.shared.isHoliday(date)
                        let isWorkday = HolidayStorage.shared.isWorkday(date)

                        Text("\(calendar.component(.day, from: date))")
                            .font(.caption2)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(
                                isToday
                                    ? .white
                                    : (isHoliday || (isWeekend && !isWorkday) ? .yellow : .primary)
                            )
                            .background(
                                Circle()
                                    .fill(isToday ? .blue : .clear)
                                    .frame(width: 16, height: 16)
                            )
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func days(for date: Date) -> [Date?] {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offsetDays = firstWeekday - 1

        return (0..<42).map { day in
            let calculatedDate = calendar.date(
                byAdding: .day, value: day - offsetDays, to: startOfMonth)
            if let date = calculatedDate,
                calendar.isDate(date, equalTo: startOfMonth, toGranularity: .month)
            {
                return date
            }
            return nil
        }
    }

    private func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7  // 1 是周日，7 是周六
    }
}

#Preview {
    CalendarMonthView(date: Date(), family: .systemMedium)
}
