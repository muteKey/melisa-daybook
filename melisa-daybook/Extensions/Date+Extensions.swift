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
