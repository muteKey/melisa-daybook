//
//  ChartsModel.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 17.05.2025.
//

import Foundation
import SwiftNavigation
import SharingGRDB

@Observable
final class ChartsModel: HashableObject {
    struct Stats: FetchKeyRequest {
        var range: DateInterval
        struct State {
            var sleepStats: [SleepStats] = []
            var feedingStats: [FeedingStats] = []
        }
        
        func fetch(_ db: Database) throws -> State {
            let sleepRes = try SleepStats.fetchAll(
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
                arguments: [
                    DateFormatter.yearMonthDay.string(from: range.start),
                    DateFormatter.yearMonthDay.string(from: range.end)
                ]
            )
            
            let feedRes = try FeedingStats.fetchAll(
                db,
                sql: """
                    SELECT COUNT(*) as count, strftime('%Y-%m-%d', startDate) as unit 
                    FROM baby_activities
                    WHERE activityType='feeding' and startDate >= date(?) and startDate <= date(?)
                    GROUP by unit
                """,
                arguments: [
                    DateFormatter.yearMonthDay.string(from: range.start),
                    DateFormatter.yearMonthDay.string(from: range.end)
                ]
            )
            
            return State(
                sleepStats: sleepRes,
                feedingStats: feedRes
            )
        }
    }
    
    @CasePathable
    enum Destination {
        case calendar
    }
    
    var destination: Destination?
    
    @ObservationIgnored
    @Dependency(\.calendar) private var calendar
    
    @ObservationIgnored
    @SharedReader var state: Stats.State
    
    init() {
        self.selectedRange = .defaultChartRange
        
        _state = SharedReader(
            wrappedValue: .init(),
            .fetch(Stats(range: _selectedRange))
        )
    }
    
    var selectedRange: DateInterval {
        didSet {
            _state = SharedReader(
                wrappedValue: .init(),
                .fetch(Stats(range: selectedRange))
            )
        }
    }
    
    var selectedDate: Date?
        
    var selectedStats: SleepStats? {
        guard let selectedDate else { return nil }
        return state.sleepStats.first {
            calendar.isDate(selectedDate, equalTo: $0.unit, toGranularity: .day)
        }
    }
    
    func dateRangeTapped() {
        destination = .calendar
    }
    
    func dateRangeSelected(_ dateRange: DateInterval) {
        selectedRange = dateRange
        destination = nil
    }
    
    func refreshTapped() {
        selectedRange = .defaultChartRange
        _state = SharedReader(
            wrappedValue: .init(),
            .fetch(Stats(range: _selectedRange))
        )
    }
}
