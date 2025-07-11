//
//  ChartsView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 17.05.2025.
//

import SwiftUI
import Charts
import SwiftUINavigation

protocol StatsPlottable: Identifiable {
    var text: String { get }
    var unit: Date { get }
    var barMark: BarMark { get }
}

extension SleepStats: StatsPlottable {
    var barMark: BarMark {
        BarMark(
            x: .value(
                String(localized: "date"),
                unit,
                unit: .day
            ),
            y: .value(
                String(localized: "sleep_time"),
                Double(duration) / 3600.0
            )
        )
    }
}

extension FeedingStats: StatsPlottable {
    var barMark: BarMark {
        BarMark(
            x: .value(
                String(localized: "date"),
                unit,
                unit: .day
            ),
            y: .value(
                String(localized: "sleep_time"),
                count
            )
        )
    }
}


struct ChartsView: View {
    @Bindable var model: ChartsModel
        
    var body: some View {
        VStack {            
            ChartSection(
                titleKey: "sleep_chart_title",
                emptyMessageKey: "no_sleep_data_available",
                stats: model.state.sleepStats,
                selectedStat: model.selectedSleepStats,
                selectedDateBinding: $model.selectedSleepDate,
            )
            
            ChartSection(
                titleKey: "feeding_chart_title",
                emptyMessageKey: "no_feeding_data_available",
                stats: model.state.feedingStats,
                selectedStat: model.selectedFeedStats,
                selectedDateBinding: $model.selectedFeedDate,
            )
        }
        .sheet(isPresented: Binding($model.destination.calendar)) {
            CalendarView(selectedRange: $model.selectedRange)
                .presentationDetents([.height(400)])
        }
        .navigationTitle("charts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.dateRangeTapped()
                } label: {
                    Image(systemName: "calendar")
                }
            }
            
            ToolbarItem(placement: .navigation) {
                Button {
                    model.refreshTapped()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }

            }
        }
    }    
}

#Preview {
    NavigationStack {
        ChartsView(model: ChartsModel())
    }
}

