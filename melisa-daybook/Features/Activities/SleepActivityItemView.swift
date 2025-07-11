//
//  SleepActivityView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 03.07.2025.
//

import SwiftUI

struct SleepActivityItemView: View {
    struct State {
        let image: Image
        let intervalText: String
        let duration: Duration
        let startDate: Date
        let endDate: Date?
        let onStop: () -> Void
    }
    
    let state: State
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                state.image
                VStack(alignment: .leading) {
                    Text(state.intervalText)
                    if state.endDate != nil {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("\(state.duration.formatted(.units(width: .narrow)))")
                        }
                    } else {
                        Text(
                            timerInterval: state.startDate...Date.distantFuture,
                            countsDown: false
                        )
                        .font(.title3)
                    }
                }
            }
            if state.endDate == nil {
                Button("stop") {
                    state.onStop()
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    SleepActivityItemView(
        state: .init(
            image: ActivityType.sleep.image,
            intervalText: "1-2",
            duration: .seconds(4),
            startDate: .now,
            endDate: nil,
            onStop: {}
        )
    )
}
