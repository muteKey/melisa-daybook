//
//  ActivityDetailsView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 02.04.2025.
//

import SwiftUI
import ComposableArchitecture

struct ActivityDetailsView: View {
    @Bindable var model: ActivityDetailsModel
    
    @State var selected = Date()
    var body: some View {
        VStack {
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

            Button("save") {
                model.saveTapped()
            }
        }
    }
}

#Preview {
    ActivityDetailsView(
        model: ActivityDetailsModel(
            activity: .init(
                id: 1,
                activityType: .sleep,
                startDate: .now,
                endDate: nil
            )
        )
    )
}
