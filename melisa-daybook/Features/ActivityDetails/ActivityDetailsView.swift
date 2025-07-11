//
//  ActivityDetailsView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 02.04.2025.
//

import SwiftUI
import Dependencies
import GRDB

struct ActivityDetailsView: View {
    @Bindable var model: ActivityDetailsModel
    
    @State var selected = Date()
    var body: some View {
        VStack {
            switch model.activity.activityType {
            case .sleep:
                Form {
                    HStack {
                        Text("duration")
                        Spacer()
                        Text(model.activity.duration.formatted())
                    }
                    HStack {
                        DatePicker(
                            "start_date",
                            selection: $model.activity.startDate
                        )
                    }

                    if model.activity.activityType == .sleep {
                        HStack {
                            if let bind = Binding(unwrapping: $model.activity.endDate) {
                                DatePicker(
                                    "end_date",
                                    selection: bind,
                                    in: model.activity.startDate...Date.distantFuture
                                )

                            } else {
                                HStack {
                                    Button("stop") {
                                        model.setEndDateTapped()
                                    }
                                }
                            }
                        }
                    }
                }

            case .feeding:
                Form {
                    HStack {
                        DatePicker(
                            "date",
                            selection: $model.activity.startDate
                        )
                    }

                }
            }

            Button("save") {
                model.saveTapped()
            }
        }
        .toolbar {
            Button {
                model.deleteTapped()
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
}

#Preview {
    prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    
    @Dependency(\.defaultDatabase) var db
    
    let activity: BabyActivity = .init(
        id: 1,
        activityType: .feeding,
        startDate: .now,
        endDate: nil
    )
    
    func seedMockDb(_ database: any DatabaseWriter, activity: BabyActivity) {
        do {
            try database.write { db in
                try activity.insert(db)
            }
        } catch {
            reportIssue(error)
        }
    }
    
    seedMockDb(db, activity: activity)
    
    return NavigationStack {
        ActivityDetailsView(
            model: ActivityDetailsModel(activity:activity)
        )
    }
}


