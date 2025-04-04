//
//  Activity.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import Foundation

enum ActivityType: String, Codable, CaseIterable {
    case sleep
}

extension ActivityType: Identifiable {
    var id: RawValue { rawValue }
}

struct BabyActivity: Decodable, Identifiable, Equatable {
    let id: UUID
    var activityType: ActivityType
    var startDate: Date
    var endDate: Date?
        
    private enum CodingKeys: CodingKey {
        case id
        case activityType
        case startDate
        case endDate
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.activityType = try container.decode(ActivityType.self, forKey: .activityType)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
    }
    
    init(id: UUID, type: ActivityType, startDate: Date, endDate: Date? = nil) {
        self.id = id
        self.activityType = type
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var intervalText: String {
        let startDateText = startDate.formatted(
            date: .omitted,
            time: .standard
        )
        let endDateText: String
        if let endDate {
            endDateText = endDate.formatted(
                date: .omitted,
                time: .standard
            )
        } else {
            endDateText = "In process"
        }
        return "\(startDateText) - \(endDateText)"
    }
    
    var duration: Duration {
        guard let endDate else { return .seconds(0) }
        let diffComponents = Calendar.current.dateComponents([.second], from: startDate, to: endDate)
        return Duration.seconds(diffComponents.second ?? 0)
    }
}
