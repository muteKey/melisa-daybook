//
//  ActivitiesTypeView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 03.04.2025.
//

import SwiftUI
import ComposableArchitecture

struct ActivitiesTypeView: View {
    @Bindable var store: StoreOf<ActivitiesFeature>
    
    var body: some View {
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
}

#Preview {
    ActivitiesTypeView(
        store: Store(initialState: ActivitiesFeature.State()) {
            ActivitiesFeature()
            ._printChanges()
        }
    )
}
