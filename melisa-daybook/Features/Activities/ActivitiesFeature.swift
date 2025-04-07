//
//  ActivitiesFeature.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 22.03.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ActivitiesFeature {
    @ObservableState
    struct State {
        var activityTypes: IdentifiedArrayOf<ActivityType> = IdentifiedArray(uniqueElements: ActivityType.allCases)
        
        var isLoading = false
        var isActivityTimerRunning: Bool = false
        var currentActivityDuration: TimeInterval = 0
        var currentDate: Date = .now
        @Presents var destination: Destination.State?
        
        var hasLoadedAllData = false
        var allActivities: IdentifiedArrayOf<BabyActivity> = []
        var currentActivities: IdentifiedArrayOf<BabyActivity> = []
        
        @ObservationStateIgnored
        @Dependency(\.calendar) private var calendar
                
        var isCurrentDateToday: Bool {
            calendar.isDateInToday(currentDate)
        }
    }
    
    @Reducer
    enum Destination {
        case activityDetails(ActivityDetailsFeature)
    }
    
    enum Action: BindableAction {
        case onAppear
        case activitiesResponse([BabyActivity])
        case startActivityTimer
        case stopActivityTimer(UUID)
        case timerTick
        case createActivityResponse(BabyActivity)
        case finishActivityResponse(BabyActivity)
        case startLiveActivity
        case stopLiveActivity
        case activityDetails(BabyActivity)
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }
    
    private enum CancelID {
        case timer
    }
    
    @Dependency(\.babyActivitiesClient) private var networkClient
    @Dependency(\.liveActivityClient) private var liveActivityClient
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.calendar) private var calendar
    @Dependency(\.date.now) private var now
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoadedAllData else { return .none }
                
                state.isLoading = true
                state.hasLoadedAllData = true
                return .run { send in
                    let response = try await networkClient.getAllActivities()
                    await send(.activitiesResponse(response))
                } catch: { error, send in
                    await send(.activitiesResponse([]))
                }
                
            case let .activitiesResponse(response):
                state.allActivities = IdentifiedArray(uniqueElements: response)
                state.currentActivities = state.allActivities.filter {
                    calendar.isDate($0.startDate, inSameDayAs: state.currentDate)
                }
                state.isLoading = false
                return .none
                
            case .startActivityTimer:
                state.isActivityTimerRunning = true
                let timerEffect: Effect<Action> = .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
                
                let liveActivityEffect: Effect<Action> = .send(.startLiveActivity)
                
                let startActivityEffect: Effect<Action> = .run { send in
                    let response = try await networkClient.createActivity()
                    await send(.createActivityResponse(response))
                } catch: { error, send in
                    print(error)
                }
                
                state.isLoading = true
                return .concatenate(startActivityEffect, liveActivityEffect, timerEffect)
            
            case .stopActivityTimer(let id):
                state.isActivityTimerRunning = false
                let liveActivityEffect: Effect<Action> = .send(.stopLiveActivity)
                let timerCancelEffect: Effect<Action> = .cancel(id: CancelID.timer)
                let finishActivityEffect: Effect<Action> = .run { send in
                    let response = try await networkClient.finishActivity(id)
                    await send(.finishActivityResponse(response))
                } catch: { error, send in
                    print(error)
                }
                state.isLoading = true

                return .concatenate(finishActivityEffect, liveActivityEffect, timerCancelEffect)

            case .timerTick:
                state.currentActivityDuration += 1
                return .none
                
            case .createActivityResponse(let activity):
                state.allActivities.insert(activity, at: 0)
                state.currentActivities = state.allActivities.filter {
                    calendar.isDate($0.startDate, inSameDayAs: state.currentDate)
                }
                state.isLoading = false
                return .none
                
            case .finishActivityResponse(let activity):
                state.isLoading = false
                guard let index = state.allActivities.firstIndex(where: { $0.id == activity.id }) else {
                    return .none
                }
                state.allActivities[index] = activity
                state.currentActivities = state.allActivities.filter {
                    calendar.isDate($0.startDate, inSameDayAs: state.currentDate)
                }

                return .none
                
            case .startLiveActivity:
                liveActivityClient.startActivity(.init(startDate: now))
                return .none
                
            case .stopLiveActivity:
                liveActivityClient.endActivity()
                return .none
                
            case .destination:
                return .none
                
            case .activityDetails(let activity):
                state.destination = .activityDetails(
                    .init(activity: activity)
                )
                return .none
            case .binding(\.currentDate):
                state.isLoading = true
                return .run { [date = state.currentDate] send in
                    let response = try await networkClient.getActivitiesForDate(date)
                    await send(.activitiesResponse(response))
                } catch: { error, send in
                    await send(.activitiesResponse([]))
                }

            case .binding:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
