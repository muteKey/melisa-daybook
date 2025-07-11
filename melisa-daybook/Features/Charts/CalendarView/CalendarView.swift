//
//  CalendarView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 11.07.2025.
//

import UIKit
import SwiftUI

struct CalendarView: UIViewRepresentable {
    @Binding var selectedRange: DateInterval
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.calendar = .current
        let selection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        selection.setSelectedDates(
            selectedRange.dates().compactMap {
                Calendar.current.dateComponents([.day, .month, .year, .weekday], from: $0)
            },
            animated: true
        )
        
        calendarView.visibleDateComponents = Calendar.current.dateComponents([.day, .month, .year, .weekday], from: selectedRange.start)
        calendarView.selectionBehavior = selection
        
        return calendarView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarSelectionMultiDateDelegate  {
        var parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            guard let date = Calendar.current.date(from: dateComponents) else { return }
            handleDateSelection(date)
            selection.setSelectedDates(
                parent.selectedRange.dates().compactMap {
                    Calendar.current.dateComponents([.day, .month, .year, .weekday], from: $0)
                },
                animated: true
            )
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
            guard let date = Calendar.current.date(from: dateComponents) else { return }
            self.parent.selectedRange = .init(start: date, end: date)
            selection.setSelectedDates(
                parent.selectedRange.dates().compactMap {
                    Calendar.current.dateComponents([.day, .month, .year, .weekday], from: $0)
                },
                animated: true
            )
        }
        
        private func handleDateSelection(_ date: Date) {
            let calendar = Calendar.current
            let newValue: DateInterval = {
                let oldValue = parent.selectedRange

                let rangeSelected = !oldValue.start.isInSameDay(in: calendar, date: oldValue.end)
                if rangeSelected {
                    return .init(start: date.startOfDay(in: calendar), end: date.endOfDay(in: calendar))
                } else if date.isInSameDay(in: calendar, date: oldValue.start) {
                    let newToDate = date.endOfDay(in: calendar)
                    return .init(start: oldValue.start, end: newToDate)
                } else if date.isInSameDay(in: calendar, date: oldValue.end) {
                    let newFromDate = date.startOfDay(in: calendar)
                    return .init(start: newFromDate, end: oldValue.end)
                } else if date < oldValue.start {
                    let newFromDate = date.startOfDay(in: calendar)
                    return .init(start: newFromDate, end: oldValue.end)
                } else {
                    let newToDate = date.endOfDay(in: calendar)
                    return .init(start: oldValue.start, end: newToDate)
                }
            }()
            parent.selectedRange = newValue
        }
    }

}
