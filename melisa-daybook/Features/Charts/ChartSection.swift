//
//  ChartSection.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 11.07.2025.
//

import SwiftUI
import Charts

struct ChartSection<StatType: StatsPlottable>: View {
    let titleKey: LocalizedStringKey
    let emptyMessageKey: LocalizedStringKey
    let stats: [StatType]
    let selectedStat: StatType?
    let selectedDateBinding: Binding<Date?>

    var body: some View {
        if stats.isEmpty {
            Text(emptyMessageKey)
                .frame(maxHeight: .infinity)
        } else {
            Text(titleKey)
            Chart {
                ForEach(stats) { data in
                    data.barMark
                    .opacity(
                        selectedStat == nil || selectedStat?.unit == data.unit ? 1 : 0.3
                    )
                }
                
                if let selected = selectedStat {
                    RuleMark(x: .value("Selected day", selected.unit, unit: .day))
                        .foregroundStyle(.white.opacity(0.8))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit)) {
                            VStack {
                                Text(selected.unit, format: .dateTime.month(.wide).day()).bold()
                                Text(selected.text)
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
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) {
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.twoDigits).day(.twoDigits))
                }
            }
            .padding()
            .chartXVisibleDomain(length: 3600 * 24 * 7)
            .chartScrollableAxes(.horizontal)
            .chartXSelection(value: selectedDateBinding.animation(.easeInOut))
        }
    }
}
