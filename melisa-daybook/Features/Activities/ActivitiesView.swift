//
//  ActivitiesView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import SwiftUI
import SwiftUINavigation
import Dependencies
import GRDB
import Foundation

struct ActivitiesView: View {
    @Bindable var model: ActivitiesModel
    @State private var calendarId: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("Sleep time: \(model.state.currentSleepDuration.formatted(.units(width: .narrow)))")
                Spacer()
            }
            
            HStack {
                Text("Awake time: \(model.state.currentAwakeDuration.formatted(.units(width: .narrow)))")
                Spacer()
            }
            
            if model.isCurrentDateToday {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(model.activityTypes) { activityType in
                            VStack {
                                activityType.image
                                Text(activityType.title).dynamicTypeSize(.small)
                            }
                            .frame(width: 65, height: 65)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                            .onTapGesture {
                                model.activityTypeTapped(activityType)
                            }
                        }
                    }
                    .frame(height: 65)
                }
            }
            
            if !model.isCurrentDateToday {
                HStack {
                    Button {
                        model.goToCurrentDate()
                    } label: {
                        Text("go_to_current_date")
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            
            DatePicker(
                model.isCurrentDateToday ? "today" : "current_date",
                selection: $model.currentDate,
                displayedComponents: [.date]
            )
            .id(calendarId)
            .onChange(of: model.currentDate) {
                calendarId += 1
            }
            
            if model.state.currentActivities.isEmpty {
                VStack {
                    Spacer()
                    Text("no_activities")
                    Spacer()
                }
            } else {
                List(model.state.currentActivities) { activity in
                    Button {
                        model.select(activity: activity)
                    } label: {
                        switch activity.activityType {
                        case .sleep:
                            SleepActivityItemView(
                                state: .init(
                                    image: ActivityType.sleep.image,
                                    intervalText: model.intervalText(for: activity),
                                    duration: activity.duration,
                                    startDate: activity.startDate,
                                    endDate: activity.endDate,
                                    onStop: {
                                        model.stopCurrentActivity()
                                    }
                                )
                            )
                        case .feeding:
                            FeedingActivityItemView(
                                state: .init(
                                    image: ActivityType.feeding.image,
                                    dateText: model.intervalText(for: activity)
                                )
                            )
                        }
                    }
                    .swipeActions {
                        Button("delete") {
                            model.deleteActivity(activity)
                        }
                        .tint(Color.red)
                    }
                }
                .refreshable {
                    await model.refresh()
                }
            }
        }
        .onAppear {
            model.viewAppeared()
        }
        .padding()
        .sheet(item: $model.destination.activityDetails, id: \.hashValue) { model in
            NavigationStack {
                ActivityDetailsView(model: model)
                    .navigationTitle("details")
                    .navigationBarTitleDisplayMode(.inline)
                
            }
        }
        .navigationTitle("melissa_daybook")
    }
}

#Preview {
    var components = DateComponents()
    components.year = 2025
    components.month = 5
    components.day = 16
    components.hour = 23
    components.minute = 59
    components.second = 30
    
    let date = Calendar.current.date(from: components)!

    prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
        $0.date.now = date
    }
    
    func seedMockDb(_ database: any DatabaseWriter) {
        do {
            try database.write { db in
                try BabyActivity(
                    activityType: .sleep,
                    startDate: .now.addingTimeInterval(60 * 60 * 24 * -1),
                    endDate: nil
                ).insert(db)
            }
        } catch {
            reportIssue(error)
        }
    }

    @Dependency(\.defaultDatabase) var db
    seedMockDb(db)
    return ActivitiesView(model: ActivitiesModel())
}

extension ActivityType {
    var image: Image {
        switch self {
        case .sleep:
            return Image(systemName: "bed.double.fill")
            
        case .feeding:
            return Image(systemName: "fork.knife.circle.fill")
        }
    }
    
    var title: String {
        switch self {
        case .sleep:
            String(localized: "sleep_value")
        case .feeding:
            String(localized: "feeding")
        }
    }
}
