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
            if let selected = model.selectedStats {
                RuleMark(x: .value("Selected day", selected.unit, unit: .day))
                    .foregroundStyle(.white.opacity(0.8))
                    .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart),y: .fit)) {
                        VStack {
                            Text(selected.unit, format: .dateTime.month(.wide).day()).bold()
                            Text(selected.formattedDuration)
                                .font(.title3.bold())
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.pink.gradient)
                        )
                    }
            }
            ForEach(model.state.monthStats) { data in
                BarMark(
                    x: .value(
                        String(localized: "date"),
                        data.unit,
                        unit: model.filter.unit
                    ),
                    y: .value(
                        String(localized: "sleep_time"),
                        Double(data.duration) / 3600.0
                    )
                )
                .opacity(
                    model.selectedDate == nil || model.selectedStats?.unit == data.unit ? 1 : 0.3
                )
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .padding()
        .chartXVisibleDomain(length: 3600 * 24 * 7)
        .chartScrollableAxes(.horizontal)
        .chartXSelection(value: $model.selectedDate.animation(.easeInOut))
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
