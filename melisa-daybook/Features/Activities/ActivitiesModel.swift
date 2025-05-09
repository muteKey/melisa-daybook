//
//  ActivitiesFeature.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import ComposableArchitecture
import Foundation
import IssueReporting
import SharingGRDB
import Combine

@Observable
final class ActivitiesModel: HashableObject {
    struct CurrentDateActivities: FetchKeyRequest {
        let date: Date
        
        struct State {
            var currentActivities: [BabyActivity] = []
        }
        
        func fetch(_ db: Database) throws -> State {
            @Dependency(\.calendar) var calendar
            
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.endOfDay(for: date)

            return try State(
                currentActivities: BabyActivity
                    .filter(Column("startDate") >= startOfDay && Column("startDate") < endOfDay)
                    .order(Column("startDate").desc)
                    .fetchAll(db)

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
    var activityTimerStartDate: Date?
    
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
    }

    var isCurrentDateToday: Bool {
        calendar.isDateInToday(currentDate)
    }
    
    func viewAppeared() {
    }
        
    func startActivityTimer() {
        activityTimerStartDate = now
        do {
            try database.write { db in
                let activity = BabyActivity(activityType: .sleep, startDate: now)
                try activity.insert(db)
            }
        } catch {
            reportIssue(error)
        }
    }
    
    func stopActivityTimer(activity: BabyActivity) {
        activityTimerStartDate = nil
        guard let id = activity.id else { return }
        
        do {
            try database.write { db in
                var activity = try BabyActivity.find(db, id: id)
                activity.endDate = now
                try activity.update(db)
            }
        } catch {
            reportIssue(error)
        }
    }
    
    func select(activity: BabyActivity) {
        let model = ActivityDetailsModel(activity: activity)
        model.onSave = { [weak self] in
            self?.destination = nil
        }
        destination = .activityDetails(model)
    }
}
