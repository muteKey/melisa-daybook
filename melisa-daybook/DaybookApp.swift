//
//  melisa_daybookApp.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import SwiftUI
import Dependencies

@main
struct DaybookApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            ActivitiesView(model: ActivitiesModel())
        }
    }
}
