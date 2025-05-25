//
//  FormatterExtensions.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 01.04.2025.
//

import Foundation

extension DateFormatter {
    public static var yearMonthDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    public static var dayMonthHoursMinutes: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, HH:mm"
        return formatter
    }
}

func formatInterval(_ start: Date, end: Date?, currentDate: Date, calendar: Calendar) -> String {
    let startDateText = dateFormat(start, currentDate: currentDate, calendar: calendar)
    let endDateText: String
    if let end {
        endDateText = dateFormat(end, currentDate: currentDate, calendar: calendar)
    } else {
        endDateText = String(localized: "in_process")
    }
    return "\(startDateText) - \(endDateText)"
}

func dateFormat(_ date: Date, currentDate: Date, calendar: Calendar) -> String {
    if calendar.isDate(date, inSameDayAs: currentDate) {
        return date.formatted(
            date: .omitted,
            time: .shortened
        )
    }
    
    return DateFormatter.dayMonthHoursMinutes.string(from: date)
}
