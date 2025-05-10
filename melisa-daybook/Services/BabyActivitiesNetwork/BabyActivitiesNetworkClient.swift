//
//  ActivitiesClient.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import Foundation
import Dependencies

struct ActivityInput: Encodable {
    var startDate: Date
    var endDate: Date
}

struct BabyActivitiesNetworkClient {
    var getAllActivities: () async throws -> [BabyActivity]
    var getActivitiesForDate: (Date) async throws -> [BabyActivity]
    var createActivity: () async throws -> BabyActivity
    var finishActivity: (Int) async throws -> BabyActivity
    var updateActivity: (Int, ActivityInput) async throws -> BabyActivity
    var deleteActivity: (Int) async throws -> Void
}

extension BabyActivitiesNetworkClient: DependencyKey {
    static var liveValue: BabyActivitiesNetworkClient {
        .init(
            getAllActivities: {
                try await ApiManager.shared.dataRequest(route: .allActivities)
            },
            getActivitiesForDate: { date in
                try await ApiManager.shared.dataRequest(
                    route: .activities,
                    queryItems: [
                        .date(DateFormatter.yearMonthDay.string(from: date))
                    ]
                )
            },
            createActivity: {
                try await ApiManager.shared.sendDataRequestDataResponse(
                    method: .post,
                    route: .activities,
                    params: Optional<String>.none
                )
            },
            finishActivity: { id in
                try await ApiManager.shared.sendDataRequestDataResponse(
                    method: .post,
                    route: .finishActivity(id),
                    params: Optional<String>.none
                )
            },
            updateActivity: { id, input in
                try await ApiManager.shared.sendDataRequestDataResponse(
                    method: .patch,
                    route: .activity(id),
                    params: input
                )
            },
            deleteActivity: { id in
                try await ApiManager.shared.sendDataRequestVoidResponse(
                    method: .delete,
                    route: .activity(id),
                    params: Optional<String>.none
                )
            }
        )
    }
    
    static var previewValue: BabyActivitiesNetworkClient {
        .init(
            getAllActivities: {
                []
            },
            getActivitiesForDate: { _ in
                [
                    .init(
                        id: 1,
                        activityType: .sleep,
                        startDate: .now,
                        endDate: nil
                    )
                ]
            },
            createActivity: {
                .init(
                    id: 2,
                    activityType: .sleep,
                    startDate: .now,
                    endDate: nil
                )
            },
            finishActivity: { id in
                .init(
                    id: Int64(id),
                    activityType: .sleep,
                    startDate: .now,
                    endDate: .now
                )
            },
            updateActivity: { id, input in
                .init(
                    id: Int64(id),
                    activityType: .sleep,
                    startDate: input.startDate,
                    endDate: input.endDate
                )
            },
            deleteActivity: { _ in
                
            }
        )
    }
}

extension DependencyValues {
    var babyActivitiesClient: BabyActivitiesNetworkClient {
        get { self[BabyActivitiesNetworkClient.self] }
        set { self[BabyActivitiesNetworkClient.self] = newValue }
    }
}
