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

                        Text("\(calendar.component(.day, from: date))")
                            .font(.caption2)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(isToday ? .white : .primary)
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
            let calculatedDate = calendar.date(byAdding: .day, value: day - offsetDays, to: startOfMonth)
            if let date = calculatedDate, calendar.isDate(date, equalTo: startOfMonth, toGranularity: .month) {
                return date
            }
            return nil
        }
    }
}

#Preview {
    CalendarMonthView(date: Date(), family: .systemMedium)
}