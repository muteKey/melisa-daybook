//
//  Dat+Extensions.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 04.04.2025.
//

import Foundation


extension Calendar {
    func daysInYear(_ year: Int) -> Int {
        let dateComponents = DateComponents(year: year)
        
        if let date = date(from: dateComponents),
           let daysRange = range(of: .day, in: .year, for: date) {
            return daysRange.count
        }
        
        return 365 // Default in case of an error
    }
    
    func endOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return self.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) ?? .now

    }
}

extension Date {
    func yearsAfter(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: Date()) ?? Date()
    }
    
    func startOfMonth(in calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))!.startOfDay(in: calendar)
    }

    func endOfMonth(in calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(in: calendar))!.endOfDay(in: calendar)
    }

    func isInSameDay(in calendar: Calendar, date: Date) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: .day)
    }

    func isInSameMonth(in calendar: Calendar, date: Date) -> Bool {
        calendar.component(.month, from: self) == calendar.component(.month, from: date)
    }
    
    func isInSameYear(in calendar: Calendar, as date: Date) -> Bool {
        calendar.component(.year, from: self) == calendar.component(.year, from: date)
    }

    func startOfDay(in calendar: Calendar) -> Date {
        calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }

    func endOfDay(in calendar: Calendar) -> Date {
        calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }

    func nextMonth(in calendar: Calendar = .current) -> Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
    
    func previousMonth(in calendar: Calendar = .current) -> Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
}

extension DateInterval {
    var nextMonth: DateInterval {
        .init(
            start: self.start.nextMonth(),
            end: self.end.nextMonth()
        )
    }
    
    var previousMonth: DateInterval {
        .init(
            start: self.start.previousMonth(),
            end: self.end.previousMonth()
        )
    }
    
    func dates(using calendar: Calendar = .current) -> [Date] {
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: self.start)

        while currentDate <= self.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }
    
    static var defaultChartRange: Self {
        .init(
            start: .now.startOfMonth(),
            end: .now.endOfMonth()
        )
    }
}

