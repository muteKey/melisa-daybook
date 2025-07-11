//
//  ChartsView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 17.05.2025.
//

import SwiftUI
import Charts
import SwiftUINavigation

struct ChartsView: View {
    @Bindable var model: ChartsModel
        
    var body: some View {
        VStack {
            if model.state.sleepStats.isEmpty {
                Text("no_sleep_data_available")
                    .frame(maxHeight: .infinity)
            } else {
                Text("sleep_chart_title")
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
                    ForEach(model.state.sleepStats) { data in
                        BarMark(
                            x: .value(
                                String(localized: "date"),
                                data.unit,
                                unit: .day
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
                        AxisValueLabel(format: .dateTime.month(.twoDigits).day(.twoDigits))
                    }
                }
                .padding()
                .chartXVisibleDomain(length: 3600 * 24 * 7)
                .chartScrollableAxes(.horizontal)
                .chartXSelection(value: $model.selectedDate.animation(.easeInOut))
            }
            
            if model.state.feedingStats.isEmpty {
                Text("no_feeding_data_available")
                    .frame(maxHeight: .infinity)
            } else {
                Text("feeding_chart_title")
                Chart {
                    ForEach(model.state.feedingStats) { data in
                        BarMark(
                            x: .value(
                                String(localized: "date"),
                                data.unit,
                                unit: .day
                            ),
                            y: .value(
                                String(localized: "sleep_time"),
                                data.count
                            )
                        )
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

            }
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

