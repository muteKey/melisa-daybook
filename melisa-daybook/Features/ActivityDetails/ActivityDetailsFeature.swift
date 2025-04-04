//
//  ActivityDetailsFeature.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 02.04.2025.
//

import Foundation
import ComposableArchitecture
import Dependencies

@Reducer
struct ActivityDetailsFeature {
    @ObservableState
    struct State {
        var activity: BabyActivity
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case setEndDateTapped
        case saveTapped
    }
    
    @Dependency(\.date.now) private var now
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .setEndDateTapped:
                state.activity.endDate = now
                return .none
                
            case .binding(_):
                return .none
                
            case .saveTapped:
                return .none
            }
        }
    }
}
