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
        var 
        var isLoading = false
        var isActivityTimerRunning: Bool = false
        var currentActivityDuration = 0
        var currentActivityDay: BabyActivityDay!
        var currentDate: Date = .now
        @Presents var destination: Destination.State?
    }
    
    @Reducer
    enum Destination {
        case activityDetails(ActivityDetailsFeature)
    }
    
    enum Action {
        case onAppear
        case activitiesResponse([BabyActivityDay])
        case startActivityTimer
        case stopActivityTimer(UUID)
        case timerTick
        case createActivityResponse(BabyActivity)
        case finishActivityResponse(BabyActivity)
        case startLiveActivity
        case stopLiveActivity
        case activityDetails(BabyActivity)
        case destination(PresentationAction<Destination.Action>)
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
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.days = IdentifiedArray(uniqueElements: generateDays())
                return .run { send in
                    let response = try await networkClient.getAllActivities()
                    await send(.activitiesResponse(response))
                } catch: { error, send in
                    await send(.activitiesResponse([]))
                }
                
            case let .activitiesResponse(response):
                let days = merge(local: state.days.elements, external: response)
                state.days = IdentifiedArray(uniqueElements: days)
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
//                state.activities.insert(activity, at: 0)
                state.isLoading = false
                return .none
                
            case .finishActivityResponse(let activity):
                state.isLoading = false
//                guard let index = state.activities.firstIndex(where: { $0.id == activity.id }) else {
//                    return .none
//                }
//                state.activities[index] = activity
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
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    private func generateDays() -> [BabyActivityDay] {
        let currentYear = calendar.component(.year, from: now)
        let daysInYear = calendar.daysInYear(currentYear)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1)) else {
            return []
        }

        let results: [BabyActivityDay] = (0..<daysInYear).compactMap {
            guard let date = calendar.date(byAdding: .day, value: $0, to: startDate) else {
                return nil
            }
            return .init(date: date, activities: [])
        }
        return results
    }
    
    private func merge(local: [BabyActivityDay], external: [BabyActivityDay]) -> [BabyActivityDay] {
        var merged: [BabyActivityDay] = []
        for day in local {
            if let index = external.firstIndex(where: { calendar.startOfDay(for: $0.date) == calendar.startOfDay(for: day.date) }) {
                let mergedDay = external[index]
                merged.append(.init(date: mergedDay.date, activities: mergedDay.activities))
            } else {
                merged.append(day)
            }
        }
        return merged
    }
    
    private func currentDayIndex() -> Int {
        let currentDate = calendar.startOfDay(for: Date())
        let index = state.days.firstIndex(where: { calendar.startOfDay(for: $0.date) == currentDate})
    }
}
