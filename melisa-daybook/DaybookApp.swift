//
//  melisa_daybookApp.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import SwiftUI
import Dependencies
import BackgroundTasks

let BACKGROUND_TASKS_ID = "com.melissadaybook.update"

@main
struct DaybookApp: App {
    var model: ActivitiesModel
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! appDatabase()
        }
        self.model = ActivitiesModel()
        registerBackgroundTask()
        scheduleAppRefresh()
    }

    var body: some Scene {
        WindowGroup {
            ActivitiesView(model: model)
        }
    }
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BACKGROUND_TASKS_ID, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: BACKGROUND_TASKS_ID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Task scheduled successfully.")
        } catch {
            print("❌ Error scheduling task: \(error)")
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        print("✅ handleLiveActivityUpdate")
        scheduleAppRefresh()

        Task {
            await model.refresh()
        }

        task.setTaskCompleted(success: true)
    }
}
