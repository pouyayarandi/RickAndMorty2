//
//  StoreTests.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/25/1401 AP.
//

import Foundation
import XCTest
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

class StoreTests: XCTestCase {
    var sut: Store<FakeState, FakeAction>!
    var recorder: Recorder<FakeState, Never>!
    var reducer: FakeReducer!
    var sideEffect: SpySideEffect!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sideEffect = .init()
        reducer = .init(sideEffect: sideEffect)
        sut = .init(reducer: reducer, state: .initial)
        recorder = sut.$state.eraseToAnyPublisher().record(on: self)
    }
    
    func testStore_whenActionArrived_shouldSendNewState() throws {
        recorder.record(timeout: 1.0) {
            self.sut.send(.initiated)
        }
        XCTAssertEqual(recorder.lastRecordedValue, .afterInitial)
    }
    
    func testStore_whenActionArrived_shouldTriggerSideEffect() throws {
        sut.send(.initiated)
        XCTAssertEqual(sideEffect.triggered!.0, .afterInitial)
        XCTAssertEqual(sideEffect.triggered!.1, .initiated)
    }
    
    func testStore_whenSideEffectEmitsAction_shouldUpdateState() async throws {
        recorder.record(timeout: 1.0, limit: 2) {
            self.sideEffect.send(.sideEffectReceived)
        }
        XCTAssertEqual(recorder.lastRecordedValue, .afterSideEffect)
    }
}
