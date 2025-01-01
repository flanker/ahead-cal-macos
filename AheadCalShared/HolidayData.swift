import Foundation

public struct HolidayData {
    public let date: Date
    public let name: String

    public init(date: Date, name: String) {
        self.date = date
        self.name = name
    }
}

public class HolidayStorage {
    public static let shared = HolidayStorage()
    private let holidays: [HolidayData]
    private let workdays: [Date]

    private init() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025

        // 初始化2025年节假日数据
        let holidaysList: [(month: Int, day: Int, name: String)] = [
            (1, 1, "元旦"),
            (1, 28, "春节"),
            (1, 29, "春节"),
            (1, 30, "春节"),
            (1, 31, "春节"),
            (2, 1, "春节"),
            (2, 2, "春节"),
            (2, 3, "春节"),
            (2, 4, "春节"),
            (4, 4, "清明节"),
            (4, 5, "清明节"),
            (4, 6, "清明节"),
            (5, 1, "劳动节"),
            (5, 2, "劳动节"),
            (5, 3, "劳动节"),
            (5, 4, "劳动节"),
            (5, 5, "劳动节"),
            (5, 31, "端午节"),
            (6, 1, "端午节"),
            (6, 2, "端午节"),
            (10, 1, "国庆中秋节"),
            (10, 2, "国庆中秋节"),
            (10, 3, "国庆中秋节"),
            (10, 4, "国庆中秋节"),
            (10, 5, "国庆中秋节"),
            (10, 6, "国庆中秋节"),
            (10, 7, "国庆中秋节"),
            (10, 8, "国庆中秋节")
        ]

        // 初始化2025年补班日期
        let workdaysList: [(month: Int, day: Int)] = [
            (1, 26),  // 春节前补班
            (2, 8),   // 春节后补班
            (4, 27),  // 劳动节补班
            (9, 28),  // 国庆中秋补班
            (10, 11)  // 国庆中秋补班
        ]

        self.holidays = holidaysList.compactMap { holiday -> HolidayData? in
            components.month = holiday.month
            components.day = holiday.day
            guard let date = calendar.date(from: components) else { return nil }
            return HolidayData(date: date, name: holiday.name)
        }

        self.workdays = workdaysList.compactMap { workday -> Date? in
            components.month = workday.month
            components.day = workday.day
            return calendar.date(from: components)
        }
    }

    public func isHoliday(_ date: Date) -> Bool {
        return holidays.contains { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) }
    }

    public func isWorkday(_ date: Date) -> Bool {
        return workdays.contains { Calendar.current.isDate($0, equalTo: date, toGranularity: .day) }
    }
}