//
//  BabyActivityWidget.swift
//  BabyActivityWidget
//
//  Created by Kirill Ushkov on 30.03.2025.
//

import WidgetKit
import SwiftUI

struct BabyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: BabyActivityAttributes.self,
            content: { context in
                BabyActivityWidgetView(state: context.state)
            },
            dynamicIsland: { context in
                DynamicIsland(
                    expanded: {
                        expandedContent(contentState: context.state)
                    },
                    compactLeading: {
                        Image(.beeIcon)
                            .resizable()
                            .frame(width: 24 , height: 24)
                    },
                    compactTrailing: {
                        TimerView(state: context.state)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.trailing)
                    },
                    minimal: {
                        Image(.beeIcon).clipShape(Circle())
                    }
                )
            }
        )
    }
}

struct BabyActivityWidgetView: View {
    let state: BabyActivityAttributes.ContentState
    
    var body: some View {
        HStack(alignment: .center) {
            Image(.beeIcon)
                .resizable()
                .frame(width: 64 , height: 64)

            TimerView(state: state)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.white)
            
            Button(intent: StopActivityIntent()) {
                Image(systemName: "stop.fill")
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
            .background(Circle().fill(.stopRed))
            .tint(.clear)

        }
        .padding()
        .background(.black)
    }
}

struct TimerView: View {
    let state: BabyActivityAttributes.ContentState

    var body: some View {
        Text(
            timerInterval: state.startDate...Date.distantFuture,
            countsDown: false
        )
    }
}

@DynamicIslandExpandedContentBuilder
private func expandedContent(contentState: BabyActivityAttributes.ContentState) -> DynamicIslandExpandedContent<some View> {
    
    DynamicIslandExpandedRegion(.center) {
        Image(.beeIcon)
            .resizable()
            .frame(width: 44 , height: 44)
    }
    DynamicIslandExpandedRegion(.bottom) {
        HStack(alignment: .center) {
            TimerView(state: contentState)
                .font(.system(size: 32, weight: .semibold))

            Button(intent: StopActivityIntent()) {
                Image(systemName: "stop.fill")
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
            .background(Circle().fill(.stopRed))
            .tint(.clear)
        }
    }
}

#Preview(
    as: .content,
    using: BabyActivityAttributes(),
    widget: {
        BabyActivityWidget()
    },
    contentStates: {
        BabyActivityAttributes.ContentState(startDate: .now)
    }
)
