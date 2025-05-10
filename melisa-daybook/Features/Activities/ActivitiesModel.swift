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
            
            let start = calendar.startOfDay(for: date)
            let end = calendar.endOfDay(for: date)
            
            let activities = try BabyActivity
                .filter(Column("startDate") >= start && Column("startDate") < end)
                .order(Column("startDate").desc)
                .fetchAll(db)
              
            let sleepDuration = try Int.fetchOne(
                db,
                sql: """
                    SELECT sum(strftime('%s', endDate) - strftime('%s', startDate))
                    FROM baby_activities
                    WHERE (startDate >= ?) AND (startDate <= ?) AND endDate IS NOT NULL
                """,
                arguments: [start, end]
            ) ?? 0
            
            let isToday = calendar.isDateInToday(date)
            
            let awakeDuration: Int
            
            if isToday {
                awakeDuration = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT strftime('%s', 'now') - strftime('%s', max(endDate))
                        FROM baby_activities
                        WHERE (startDate >= ?) AND (startDate <= ?) AND endDate IS NOT NULL
                    """,
                    arguments: [start, end]
                ) ?? 0
            } else {
                awakeDuration = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT strftime('%s', ?) - strftime('%s', max(endDate))
                        FROM baby_activities
                        WHERE (startDate >= ?) AND (startDate <= ?) AND endDate IS NOT NULL
                    """,
                    arguments: [end, start, end]
                ) ?? 0
            }
            
            return State(
                currentActivities: activities,
                currentSleepDuration: Duration.seconds(sleepDuration),
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
    
    func viewAppeared() {
    }
        
    func startActivityTimer() {
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
    
    func stopActivityTimer(activity: BabyActivity) {
        guard let id = activity.id else { return }
        
        do {
            try database.write { db in
                var activity = try BabyActivity.find(db, id: id)
                activity.endDate = now
                try activity.update(db)
                liveActivityClient.endActivity()
            }
        } catch {
            reportIssue(error)
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
    
    func stopCurrentActivity() {
        do {
            try database.write { db in
                let start = calendar.startOfDay(for: currentDate)
                let end = calendar.endOfDay(for: currentDate)
             
                var currentActivity = try BabyActivity.fetchOne(
                    db,
                    sql: """
                        SELECT *
                        FROM baby_activities
                        WHERE (startDate >= ?) AND (startDate <= ?) AND endDate IS NULL
                    """,
                    arguments: [start, end]
                )
                
                currentActivity?.endDate = now
                try currentActivity?.update(db)
            }
        } catch {
            reportIssue(error)
        }
    }
}
