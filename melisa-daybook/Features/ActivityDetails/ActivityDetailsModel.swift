//
//  ActivityDetailsFeature.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 02.04.2025.
//

import Foundation
import Dependencies
import SwiftUINavigation
import IssueReporting

@Observable
final class ActivityDetailsModel: HashableObject {
    @ObservationIgnored
    @Dependency(\.date.now) private var now

    @ObservationIgnored
    @Dependency(\.defaultDatabase) private var database
    
    @ObservationIgnored
    @Dependency(\.liveActivityClient) private var liveActivityClient
    
    var onFinish: () -> Void = unimplemented()
    
    var activity: BabyActivity
    init(activity: BabyActivity) {
        self.activity = activity
    }
        
    func setEndDateTapped() {
        activity.endDate = now
    }
    
    func saveTapped() {
        do {
            try database.write { db in
                try activity.update(db)
                if activity.endDate == nil {
                    liveActivityClient.updateActivity(.init(startDate: activity.startDate))
                }
                onFinish()
            }
        } catch {
            reportIssue(error)
        }
    }
    
    func deleteTapped() {
        do {
            _ = try database.write { db in
                try activity.delete(db)
                onFinish()
            }
        } catch {
            reportIssue(error)
        }
    }
}
