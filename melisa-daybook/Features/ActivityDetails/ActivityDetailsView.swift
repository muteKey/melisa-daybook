//
//  ActivityDetailsView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 02.04.2025.
//

import SwiftUI
import ComposableArchitecture

struct ActivityDetailsView: View {
    @Bindable var store: StoreOf<ActivityDetailsFeature>
    
    @State var selected = Date()
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(store.activity.duration.formatted())
                }
                HStack {
                    DatePicker(
                        "Start date",
                        selection: $store.activity.startDate
                    )
                }
                HStack {
                    if let bind = Binding(unwrapping: $store.activity.endDate) {
                        DatePicker(
                            "End date",
                            selection: bind,
                            in: store.activity.startDate...Date.distantFuture
                        )
                        
                    } else {
                        HStack {
                            Button("Stop") {
                                store.send(.setEndDateTapped)
                            }
                        }
                    }
                }
            }

            Button("Save") {
                store.send(.saveTapped)
            }
        }
    }
}

#Preview {
    ActivityDetailsView(
        store: Store(initialState:
                        ActivityDetailsFeature.State(
                            activity: .init(
                                id: .init(),
                                type: .sleep,
                                startDate: .now,
                                endDate: nil
                            )
                        )
                    ) {
                        ActivityDetailsFeature()
                            ._printChanges()
                    }
    )
}
