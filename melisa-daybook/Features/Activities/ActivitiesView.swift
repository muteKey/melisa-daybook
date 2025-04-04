//
//  ActivitiesView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import SwiftUI
import ComposableArchitecture

struct ActivitiesView: View {
    @Bindable var store: StoreOf<ActivitiesFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                ActivitiesTypeView(store: store)
                
//                if let date = store.currentActivity?.startDate {
//                    Text(
//                        timerInterval: date...Date.distantFuture,
//                        countsDown: false,
//                        showsHours: true
//                    )
//                }
                
                ScrollView(.horizontal) {
                    ActivitiesPageView(
                        activities: store.currentActivityDay?.activities ?? [],
                        onSelectActivity: { activity in
                            store.send(.activityDetails(activity))
                        },
                        onStopActivityTimer: { id in
                            store.send(.stopActivityTimer(id))
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollTargetLayout()
                    .onAppear {
                        store.send(.onAppear)
                    }
                    .background(Color.red)
                }
                .scrollTargetBehavior(.paging)
                .background(Color.yellow)
                
//                ScrollView(.horizontal) {
//                    if store.activities.isEmpty {
//                        VStack {
//                            Spacer()
//                            Text("No activities today")
//                            Spacer()
//                        }
//                    } else {
//                        ScrollView(.vertical) {
//                            LazyVStack(spacing: 0) {
//                                ForEach(store.activities) { activity in
//                                    Button {
//                                        store.send(.activityDetails(activity))
//                                    } label: {
//                                        VStack(alignment: .leading) {
//                                            HStack {
//                                                activity.activityType.image
//                                                VStack(alignment: .leading) {
//                                                    Text(activity.activityType.title)
//                                                    Text(activity.activityType.intervalText)
//                                                }
//                                            }
//                                            if activity.endDate == nil {
//                                                Button("Stop") {
//                                                    store.send(.stopActivityTimer(activity.id))
//                                                }
//                                                .padding()
//                                                .background(Color(red: 0, green: 0, blue: 0.5))
//                                                .clipShape(Capsule())
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    List(store.activities) { activity in
//                        Button {
//                            store.send(.activityDetails(activity))
//                        } label: {
//                            VStack(alignment: .leading) {
//                                HStack {
//                                    activity.activityType.image
//                                    VStack(alignment: .leading) {
//                                        Text(activity.activityType.title)
//                                        Text(activity.intervalText)
//                                    }
//                                }
//                                if activity.endDate == nil {
//                                    Button("Stop") {
//                                        store.send(.stopActivityTimer(activity.id))
//                                    }
//                                    .padding()
//                                    .background(Color(red: 0, green: 0, blue: 0.5))
//                                    .clipShape(Capsule())
//                                }
//                            }
//                        }
//                    }
//                    }
//                }
            }
            .padding()
            .navigationTitle("Melisa Daybook")
            .sheet(
                item: $store.scope(
                    state: \.destination?.activityDetails,
                    action: \.destination.activityDetails
                )
            ) { store in
                NavigationStack {
                    ActivityDetailsView(store: store)
                        .navigationTitle("Details")
                        .navigationBarTitleDisplayMode(.inline)
                        
                }
            }
        }
    }
}

#Preview {
    ActivitiesView(
        store: Store(initialState: ActivitiesFeature.State()) {
            ActivitiesFeature()
            ._printChanges()
        }
    )
}

extension ActivityType {
    var image: Image {
        switch self {
        case .sleep:
            return Image(systemName: "bed.double.fill")
        }
    }
    
    var title: String {
        switch self {
        case .sleep:
            "Sleep"
        }
    }
}
