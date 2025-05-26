//
//  ChartsView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 17.05.2025.
//

import SwiftUI
import Charts

struct ChartsView: View {
    @Bindable var model: ChartsModel
    
    var body: some View {
        Chart {
            ForEach(model.state.monthStats) { data in
                BarMark(
                    x: .value(
                        String(localized: "date"),
                        model.dateFor(value: data.unit),
                        unit: model.filter.unit
                    ),
                    y: .value(
                        String(localized: "sleep_time"),
                        Double(data.duration) / 3600.0
                    )
                )
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartXVisibleDomain(length: 3600 * 24 * 7)
        .navigationTitle("charts")
        .toolbar {
            ToolbarItem {
                Picker("sort", selection: $model.filter) {
                    ForEach(DateFilter.allCases) {
                        Text($0.title)
                    }
                }
            }
        }
    }
}

#Preview {
    ChartsView(model: ChartsModel())
}
