
import ActivityKit
import Foundation

extension LiveActivityClient {
    static var live: Self {
        var activity: Activity<BabyActivityAttributes>?
        
        return .init(
            startActivity: { state in
                guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                    return
                }
                                
                let attr = BabyActivityAttributes()
                let content = ActivityContent(
                    state: BabyActivityAttributes.ContentState(startDate: .now),
                    staleDate: nil
                )
                do {
                    activity = try Activity<BabyActivityAttributes>.request(
                        attributes: attr,
                        content: content,
                        pushType: nil
                    )
                                        
                } catch {
                    print(error)
                }
            },
            updateActivity: { state in
                guard let activity else { return }
                
                let content = ActivityContent(
                    state: state,
                    staleDate: nil
                )
                Task {
                    await activity.update(content)
                }
            },
            endActivity: {
                Task {
                    await activity?.end(nil, dismissalPolicy: .immediate)
                }
            },
            endExistingActivities: {
                for activity in Activity<BabyActivityAttributes>.activities {
                    Task {
                        await activity.end(nil, dismissalPolicy: .immediate)
                    }
                }
            },
            hasActivities: {
                Activity<BabyActivityAttributes>.activities.count > 0
            }
        )
    }
}
