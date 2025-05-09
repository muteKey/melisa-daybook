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

struct ActivitiesView: View {
    @Bindable var model: ActivitiesModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if model.isCurrentDateToday {
                    ScrollView(.horizontal, showsIndicators: false) {
                        ForEach(model.activityTypes) { activityType in
                            VStack {
                                activityType.image
                                Text(activityType.title)
                            }
                            .frame(width: 65, height: 65)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                            .onTapGesture {
                                model.startActivityTimer()
                            }
                        }
                    }
                }
                                
                DatePicker(
                    model.isCurrentDateToday ? "today" : "current_date",
                    selection: $model.currentDate,
                    displayedComponents: [.date]
                )
                
                if let startDate = model.activityTimerStartDate {
                    Text(
                        timerInterval: startDate...Date.distantFuture,
                        countsDown: false
                    )
                    .font(.title3)
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
                            VStack(alignment: .leading) {
                                HStack {
                                    activity.activityType.image
                                    VStack(alignment: .leading) {
                                        Text(activity.activityType.title)
                                        Text(activity.intervalText)
                                    }
                                }
                                if activity.endDate == nil {
                                    Button("stop") {
                                        model.stopActivityTimer(activity: activity)
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
}

extension DatabaseWriter where Self == DatabaseQueue {
    static var activityDatabase: Self {
        let databaseQueue = try! DatabaseQueue()
        var migrator = DatabaseMigrator()
        migrator.registerMigration("Create Baby Activities Table") { db in
            try db.create(table: "baby_activities", options: [.strict]) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("activityType", .text).notNull()
                t.column("startDate", .text).notNull()
                t.column("endDate", .text)
            }
        }
        try! migrator.migrate(databaseQueue)
        
        try! databaseQueue.write { db in
            try BabyActivity(
                activityType: .sleep,
                startDate: .now.addingTimeInterval(-3600),
                endDate: .now.addingTimeInterval(-600)
            ).insert(db)
        }
        
        return databaseQueue
    }
}

#Preview {
    let model = withDependencies {
        $0.defaultDatabase = .activityDatabase
    } operation: {
        ActivitiesModel()
    }

    return ActivitiesView(model: model)
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
            String(localized: "sleep_value")
        }
    }
}
