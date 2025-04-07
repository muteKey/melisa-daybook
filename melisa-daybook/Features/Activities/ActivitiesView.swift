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
                if store.isCurrentDateToday {
                    ScrollView(.horizontal, showsIndicators: false) {
                        ForEach(store.activityTypes) { activityType in
                            VStack {
                                activityType.image
                                Text(activityType.title)
                            }
                        }
                        .frame(width: 65, height: 65)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                        .onTapGesture {
                            store.send(.startActivityTimer)
                        }
                    }
                }
                                
                DatePicker(
                    "Date",
                    selection: $store.currentDate,
                    displayedComponents: [.date]
                )
                
                if store.isActivityTimerRunning {
                    Text(
                        Duration
                            .seconds(store.currentActivityDuration)
                            .formatted()
                    )
                    .font(.title3)
                }

                if store.currentActivities.isEmpty {
                    VStack {
                        Spacer()
                        Text("No activities")
                        Spacer()
                    }
                } else {
                    List(store.currentActivities) { activity in
                        Button {
                            store.send(.activityDetails(activity))
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
                                        store.send(.stopActivityTimer(activity.id))
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
            .onAppear {
                store.send(.onAppear)
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
