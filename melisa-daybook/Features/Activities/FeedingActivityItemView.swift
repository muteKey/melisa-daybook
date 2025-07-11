//
//  FeedingActivityView.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 02.07.2025.
//

import SwiftUI

struct FeedingActivityItemView: View {
    struct State {
        let image: Image
        let dateText: String
    }
    
    let state: State
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                state.image
                VStack(alignment: .leading) {
                    Text(state.dateText)
                }
            }
        }
    }
}

#Preview {
    FeedingActivityItemView(
        state: .init(
            image: Image(systemName: "fork.knife.circle.fill"),
            dateText: "Testr"
        )
    )
}
