//
//  Interface.swift
//  bestextender
//
//  Created by Kirill Ushkov on 23.01.2025.
//

import Foundation
import Dependencies

struct LiveActivityClient {
    var startActivity: (BabyActivityAttributes.ContentState) -> Void
    var updateActivity: (BabyActivityAttributes.ContentState) -> Void
    var endActivity: () -> Void
    var endExistingActivities: () -> Void
    var hasActivities: () -> Bool
}

extension LiveActivityClient: DependencyKey {
    static var liveValue: LiveActivityClient = .live
}

extension DependencyValues {
    var liveActivityClient: LiveActivityClient {
        get { self[LiveActivityClient.self] }
        set { self[LiveActivityClient.self] = newValue }
    }
}
