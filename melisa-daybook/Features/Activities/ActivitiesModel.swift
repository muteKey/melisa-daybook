//
//  ActivitiesFeature.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import Foundation
import IssueReporting
import SharingGRDB
import Combine
import SwiftNavigation

@Observable
final class ActivitiesModel: HashableObject {
    struct CurrentDateActivities: FetchKeyRequest {
        let date: Date
        
        struct State {
            var currentActivities: [BabyActivity] = []
            var currentSleepDuration: Duration = .seconds(0)
            var currentAwakeDuration: Duration = .seconds(0)
        }
        
        func fetch(_ db: Database) throws -> State {
            @Dependency(\.calendar) var calendar
                        
            let activities = try BabyActivity.fetchAll(
                db,
                sql: """
                    SELECT * 
                    FROM baby_activities
                    WHERE startDate >= date(?, 'start of day', 'localtime') 
                        AND startDate <= date(?, 'start of day', 'localtime', '+23:59:59')
                        OR 
                        (endDate >= date(?, 'start of day', 'localtime')  
                        AND endDate <= date(?, 'start of day', 'localtime', '+23:59:59'))
                    ORDER BY startDate DESC
                """,
                arguments: [date, date, date, date]
            )
            
            let sleepDurationDuringDay = try Int.fetchOne(
                db,
                sql: """
                    SELECT sum(strftime('%s', endDate) - strftime('%s', startDate))
                    FROM baby_activities
                    WHERE startDate >= date(?, 'start of day', 'localtime') 
                        AND startDate <= date(?, 'start of day', 'localtime', '+23:59:59')
                        AND endDate >= date(?, 'start of day', 'localtime')  
                        AND endDate <= date(?, 'start of day', 'localtime', '+23:59:59')
                        AND activityType = 'sleep'
                """,
                arguments: [date, date, date, date]
            ) ?? 0
            
            let sleepDurationAfterMidnight = try Int.fetchOne(
                db,
                sql: """
                    SELECT sum(strftime('%s', endDate) - strftime('%s', date(endDate, 'start of day', 'localtime')))
                        FROM baby_activities
                    WHERE 
                    (startDate < date(?, 'start of day', 'localtime') 
                     OR startDate > date(?, 'start of day', 'localtime', '+23:59:59'))                
                    AND (endDate >= date(?, 'start of day', 'localtime')) 
                    AND (endDate <= date(?, 'start of day', 'localtime', '+23:59:59'))
                    AND activityType = 'sleep'
                """,
                arguments: [date, date, date, date]
            ) ?? 0
            
            let sleepDurationBeforeMidnight = try Int.fetchOne(
                db,
                sql: """
                    SELECT strftime('%s', date(?, 'start of day', 'localtime', '+23:59:59')) - strftime('%s', startDate)
                        FROM baby_activities
                    WHERE 
                        startDate >= date(?, 'start of day', 'localtime')
                        AND startDate <= date(?, 'start of day', 'localtime', '+23:59:59')
                    AND ("endDate" > date(?, 'start of day', 'localtime', '+23:59:59'))
                    AND activityType = 'sleep'
                """,
                arguments: [date, date, date, date]
            ) ?? 0
            
            let isToday = calendar.isDateInToday(date)
            
            let awakeDuration: Int
            
            if isToday {
                awakeDuration = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT strftime('%s', 'now') - strftime('%s', max(endDate))
                        FROM baby_activities
                        WHERE (startDate >= date(?, 'start of day', 'localtime'))
                        AND (startDate <= date(?, 'start of day', 'localtime', '+23:59:59')) 
                        AND endDate IS NOT NULL
                        AND activityType = 'sleep'
                    """,
                    arguments: [date, date]
                ) ?? 0
            } else {
                awakeDuration = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT strftime('%s', date(?, 'start of day', 'localtime', '+23:59:59')) - strftime('%s', max(endDate))
                        FROM baby_activities
                        WHERE (startDate >= date(?, 'start of day', 'localtime')) 
                        AND (startDate <= date(?, 'start of day', 'localtime', '+23:59:59'))
                        AND (endDate >= date(?, 'start of day', 'localtime')) 
                        AND (endDate <= date(?, 'start of day', 'localtime', '+23:59:59'))
                        AND activityType = 'sleep'
                    """,
                    arguments: [date, date, date, date, date]
                ) ?? 0
            }
            
            return State(
                currentActivities: activities,
                currentSleepDuration: Duration.seconds(sleepDurationDuringDay + sleepDurationBeforeMidnight + sleepDurationAfterMidnight),
                currentAwakeDuration: Duration.seconds(awakeDuration)
            )
        }
    }
    
    @CasePathable
    enum Destination {
        case activityDetails(ActivityDetailsModel)
    }
    var destination: Destination?

    let activityTypes = ActivityType.allCases
    var isLoading = false
    
    var currentDate: Date = .now {
        didSet {
            $state = SharedReader(
                wrappedValue: state,
                    .fetch(CurrentDateActivities(date: currentDate))
            )
        }
    }
    
    @ObservationIgnored
    @SharedReader var state: CurrentDateActivities.State

    @ObservationIgnored
    @Dependency(\.liveActivityClient) private var liveActivityClient
    @ObservationIgnored
    @Dependency(\.continuousClock) private var clock
    @ObservationIgnored
    @Dependency(\.calendar) private var calendar
    @ObservationIgnored
    @Dependency(\.date.now) private var now
    @ObservationIgnored
    @Dependency(\.defaultDatabase) private var database
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        _state = SharedReader(
            wrappedValue: .init(),
            .fetch(CurrentDateActivities(date: .now))
        )
        
        NotificationCenter.default
            .publisher(for: .stopActivity)
            .sink { [weak self] _ in
                self?.stopCurrentActivity()
            }.store(in: &cancellables)
    }

    var isCurrentDateToday: Bool {
        calendar.isDateInToday(currentDate)
    }
    
    func viewAppeared() {}
    
    func refresh() async {
        do {
            try await _state.load()
        } catch {
            reportIssue(error)
        }
    }
    
    func activityTypeTapped(_ activityType: ActivityType) {
        switch activityType {
        case .sleep:
            startSleepTimer()
        case .feeding:
            recordFeeding()
        }
    }
    
    func deleteActivity(_ activity: BabyActivity) {
        do {
            _ = try database.write { db in
                try activity.delete(db)
            }
        } catch {
            reportIssue(error)
        }
    }
    
    func select(activity: BabyActivity) {
        let model = ActivityDetailsModel(activity: activity)
        model.onFinish = { [weak self] in
            self?.destination = nil
        }
        destination = .activityDetails(model)
    }
    
    func goToCurrentDate() {
        currentDate = .now
    }
    
    func stopCurrentActivity() {
        liveActivityClient.endExistingActivities()

        do {
            try database.write { db in
                guard var currentActivity = try BabyActivity.fetchOne(
                    db,
                    sql: """
                        SELECT *
                        FROM baby_activities
                        WHERE endDate IS NULL 
                        AND activityType = 'sleep'
                    """,
                ) else {
                    return
                }

                currentActivity.endDate = now
                try currentActivity.update(db)
            }
        } catch {
            reportIssue(error)
        }
    }
    
    func intervalText(for activity: BabyActivity) -> String {
        switch activity.activityType {
        case .sleep:
            formatInterval(
                activity.startDate,
                end: activity.endDate,
                currentDate: currentDate,
                calendar: calendar
            )
        case .feeding:
            dateFormat(
                activity.startDate,
                currentDate: currentDate,
                calendar: calendar
            )
        }
    }
    
    private func startSleepTimer() {
        do {
            try database.write { db in
                let activity = BabyActivity(activityType: .sleep, startDate: now)
                try activity.insert(db)
                liveActivityClient.startActivity(.init(startDate: now))
            }
        } catch {
            reportIssue(error)
        }
    }
    
    private func recordFeeding() {
        do {
            try database.write { db in
                let activity = BabyActivity(activityType: .feeding, startDate: now, endDate: now)
                try activity.insert(db)
            }
        } catch {
            reportIssue(error)
        }
    }
}
