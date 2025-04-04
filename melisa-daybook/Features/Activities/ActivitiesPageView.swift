//
//  ActivitiesPageView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 03.04.2025.
//

import SwiftUI
import ComposableArchitecture

struct ActivitiesPageView: View {
    let activities: [BabyActivity]
    let onSelectActivity: (BabyActivity) -> Void
    let onStopActivityTimer: (UUID) -> Void
    var body: some View {
        if activities.isEmpty {
            VStack {
                Spacer()
                Text("No activities")
                Spacer()
            }
        } else {
            List(activities) { activity in
                Button {
                    onSelectActivity(activity)
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            activity.activityType.image
                            VStack(alignment: .leading) {
                                Text(activity.activityType.title)
                                Text(activity.intervalText)
                            }
                        }
                        if activity.endDate == nil {
                            Button("Stop") {
                                onStopActivityTimer(activity.id)
                            }
                            .padding()
                            .background(Color(red: 0, green: 0, blue: 0.5))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    return ActivitiesPageView(
        activities: [],
        onSelectActivity: unimplemented(),
        onStopActivityTimer: unimplemented()
    )
}
