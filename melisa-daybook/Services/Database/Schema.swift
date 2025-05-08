//
//  Schema.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 06.05.2025.
//

import Foundation
import GRDB

enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case sleep
    
    var id: RawValue { rawValue }
}

struct BabyActivity: Codable, Identifiable, Equatable, PersistableRecord, FetchableRecord {
    var id: Int64?
    var activityType: ActivityType
    
    var startDate: Date
    var endDate: Date?
    
    static var databaseTableName: String {
        "baby_activities"
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    var intervalText: String {
        let startDateText = startDate.formatted(
            date: .omitted,
            time: .shortened
        )
        let endDateText: String
        if let endDate {
            endDateText = endDate.formatted(
                date: .omitted,
                time: .shortened
            )
        } else {
            endDateText = String(localized: "in_process")
        }
        return "\(startDateText) - \(endDateText)"
    }
    
    var duration: Duration {
        guard let endDate else { return .seconds(0) }
        let diffComponents = Calendar.current.dateComponents([.second], from: startDate, to: endDate)
        return Duration.seconds(diffComponents.second ?? 0)
    }
}
