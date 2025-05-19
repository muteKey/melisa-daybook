//
//  TabsModel.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 17.05.2025.
//

import Foundation
import SwiftNavigation

enum AppTab: Hashable {
    case activities
    case charts
}

@Observable
final class TabsModel: HashableObject {
    var currentTab: AppTab
    
    var activities: ActivitiesModel
    var charts: ChartsModel
    
    init(tab: AppTab = .activities) {
        self.currentTab = tab
        self.activities = ActivitiesModel()
        self.charts = ChartsModel()
        bind()
    }

    private func bind() {
        
    }
    
    func refresh() async {
        
    }
}
