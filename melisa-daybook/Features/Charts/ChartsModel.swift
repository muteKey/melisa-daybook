//
//  ChartsModel.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 17.05.2025.
//

import Foundation
import SwiftNavigation
import SharingGRDB

enum DateFilter: CaseIterable, Identifiable {
    case day
    case month
    
    var title: String {
        switch self {
        case .day:
            String(localized: "day")
        case .month:
            String(localized: "month")
        }
    }
    
    var id: Self { return self }
    
    var filter: String {
        switch self {
        case .day:
            "%Y-%m-%d"
        case .month:
            "%m-%Y"
        }
    }
    
    var unit: Calendar.Component {
        switch self {
        case .day:
            .day
        case .month:
            .month
        }
    }
}

@Observable
final class ChartsModel: HashableObject {
    struct Stats: FetchKeyRequest {
        var dateFilter: DateFilter
        struct State {
            var monthStats: [ActivityStats] = []
        }
        
        func fetch(_ db: Database) throws -> State {
            let res = try ActivityStats.fetchAll(
                db,
                sql: """
                WITH RECURSIVE days(day) AS (
                  SELECT DATE(?)
                  UNION ALL
                  SELECT DATE(day, '+1 day')
                  FROM days
                  WHERE day < ?
                ),
                activity_durations AS (
                  SELECT
                    ba.id,
                    ba.activityType,
                    ba.startDate,
                    COALESCE(ba.endDate, CURRENT_TIMESTAMP) AS endDate,
                    d.day
                  FROM baby_activities ba
                  JOIN days d
                    ON d.day BETWEEN DATE(ba.startDate) AND DATE(COALESCE(ba.endDate, CURRENT_TIMESTAMP))
                ),
                split_durations AS (
                  SELECT
                    day,
                    activityType,
                    MAX(DATETIME(day)) AS interval_start,
                    MIN(DATETIME(day, '+1 day'), endDate) AS interval_end,
                    (strftime('%s', MIN(DATETIME(day, '+1 day'), endDate)) -
                     strftime('%s', MAX(DATETIME(day), startDate))) AS duration_seconds
                  FROM activity_durations
                  GROUP BY id, day
                )
                SELECT 
                  day AS unit,
                  activityType,
                  SUM(duration_seconds) AS duration
                FROM split_durations
                GROUP BY day, activityType
                ORDER BY day, activityType;
                """,
                arguments: ["2025-05-01", "2025-05-31"]
            )
            
            return State(monthStats: res)
        }
    }
    
    var selectedDate: Date?
    var selectedStats: ActivityStats? {
        guard let selectedDate else { return nil }
        return state.monthStats.first {
            calendar.isDate(selectedDate, equalTo: $0.unit, toGranularity: .day)
        }
    }
    
    var filter: DateFilter = .day {
        didSet {
            _state = SharedReader(
                wrappedValue: .init(),
                .fetch(Stats(dateFilter: filter))
            )
        }
    }
    
    @ObservationIgnored
    @Dependency(\.calendar) private var calendar
    
    @ObservationIgnored
    @SharedReader var state: Stats.State
    
    init() {
        _state = SharedReader(
            wrappedValue: .init(),
            .fetch(Stats(dateFilter: self._filter))
        )
    }
}
