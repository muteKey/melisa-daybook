//
//  StopTrainingIntent.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 30.03.2025.
//


import AppIntents

struct StopActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Activity"
    
    static var openAppWhenRun: Bool { true }
    
    @MainActor
    func perform() async throws -> some IntentResult {
//        NotificationCenter.default.post(name: .stopTraining, object: nil)
        
        return .result()
    }
}
