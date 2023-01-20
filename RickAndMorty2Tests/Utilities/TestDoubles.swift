//
//  TestDoubles.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/30/1401 AP.
//

import Foundation
import Combine
@testable import RickAndMorty2

enum FakeState: State {
    case initial
    case afterInitial
    case afterSideEffect
}

enum FakeAction: Action {
    case initiated
    case sideEffectReceived
}

class FakeReducer: Reducer {
    var lastReduced: (FakeState, FakeAction)?
    var sideEffect: any SideEffect<FakeState, FakeAction>
    
    init(sideEffect: any SideEffect<FakeState, FakeAction>) {
        self.sideEffect = sideEffect
    }
    
    func reduce(_ state: FakeState, with action: FakeAction) -> FakeState {
        lastReduced = (state, action)
        switch (state, action) {
        case (.initial, .initiated): return .afterInitial
        case (.initial, .sideEffectReceived): return .afterSideEffect
        default: return state
        }
    }
}

class SpySideEffect: SideEffect {
    var triggered: (FakeState, FakeAction)?
    var action = PassthroughSubject<FakeAction, Never>()
    
    var publisher: AnyPublisher<FakeAction, Never> {
        action.eraseToAnyPublisher()
    }
    
    func trigger(state: FakeState, action: FakeAction) {
        triggered = (state, action)
    }
    
    func send(_ action: FakeAction) {
        self.action.send(action)
    }
}

extension Array where Element == CharacterModel {
    static var fake: Self {
        [.init(id: 0, name: "Test", status: .alive)]
    }
}

extension NSError {
    static var fake: Self {
        .init(domain: "error", code: -1)
    }
}
