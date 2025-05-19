//
//  TabsView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 17.05.2025.
//

import SwiftUI
import SwiftNavigation

struct TabsView: View {
    @Bindable var model: TabsModel
    
    var body: some View {
        TabView(selection: $model.currentTab) {
            Tab("activities",
                systemImage: "list.bullet.circle",
                value: .activities
            ) {
                NavigationStack {
                    ActivitiesView(model: model.activities)
                }
            }
            
            Tab(
                "charts",
                systemImage: "water.waves",
                value: .charts
            ) {
                NavigationStack {
                    ChartsView(model: model.charts)
                }
            }
        }
    }
}

#Preview {
    TabsView(model: TabsModel())
}
