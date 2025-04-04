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
}
