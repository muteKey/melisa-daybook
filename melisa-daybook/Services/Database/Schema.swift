//
//  Schema.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 06.05.2025.
//

import Foundation
import GRDB
import SharingGRDB

enum ActivityType: String, Codable, CaseIterable, Identifiable, QueryBindable {
    case sleep
    case feeding
    
    var id: RawValue { rawValue }
}

@Table("baby_activities")
struct BabyActivity: Codable, Identifiable, Equatable, PersistableRecord, FetchableRecord {
    var id: Int64?
    var activityType: ActivityType
    
    @Column(as: Date.ISO8601Representation.self)
    var startDate: Date
    
    @Column(as: Date.ISO8601Representation?.self)
    var endDate: Date?
    
    static var databaseTableName: String {
        "baby_activities"
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
        
    var duration: Duration {
        guard let endDate else { return .seconds(0) }
        let diffComponents = Calendar.current.dateComponents([.second], from: startDate, to: endDate)
        return Duration.seconds(diffComponents.second ?? 0)
    }
}

struct SleepStats: FetchableRecord, Identifiable {
    let id = UUID()
    var duration: Int
    var unit: Date
    
    init(row: GRDB.Row) throws {
        self.duration = row["duration"]
        self.unit = row["unit"]
    }
    
    var text: String {
        Duration.seconds(duration).formatted(.units(width: .narrow, maximumUnitCount: 2))
    }
}

struct FeedingStats: FetchableRecord, Identifiable {
    let id = UUID()
    var count: Int
    var unit: Date
    
    init(row: GRDB.Row) throws {
        self.count = row["count"]
        self.unit = row["unit"]
    }
    
    var text: String {
        count.description
    }
}
