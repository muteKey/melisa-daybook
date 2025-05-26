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
                    SELECT sum(strftime('%s', endDate) - strftime('%s', startDate)) as duration, STRFTIME(?,startDate) as unit
                    FROM baby_activities
                    WHERE endDate is not NULL                  
                    GROUP BY STRFTIME(?, startDate)
                    ORDER BY unit 
                """,
                arguments: [dateFilter.filter, dateFilter.filter]
            )
            
            return State(monthStats: res)
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
    @SharedReader var state: Stats.State
    
    init() {
        _state = SharedReader(
            wrappedValue: .init(),
            .fetch(Stats(dateFilter: self._filter))
        )
    }
        
    func dateFor(value: String) -> Date {
        switch filter {
        case .day:
            return DateFormatter.yearMonthDay.date(from: value)!
        case .month:
            return DateFormatter.monthYear.date(from: value)!
        }
    }
}
