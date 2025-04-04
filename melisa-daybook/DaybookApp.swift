//
//  melisa_daybookApp.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct DaybookApp: App {
    static let store = Store(initialState: ActivitiesFeature.State()) {
        ActivitiesFeature()
        ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            ActivitiesView(store: DaybookApp.store)
        }
    }
}
