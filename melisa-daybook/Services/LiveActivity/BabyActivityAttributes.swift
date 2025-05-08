//
//  TrainingAttributes.swift
//  bestextender
//
//  Created by Kirill Ushkov on 23.01.2025.
//

import ActivityKit
import Foundation

struct BabyActivityAttributes: ActivityAttributes {
    public typealias TrainingStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        let startDate: Date
    }
}
