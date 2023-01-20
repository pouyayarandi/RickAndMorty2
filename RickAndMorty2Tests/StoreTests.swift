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
        recorder = sut.$state.eraseToAnyPublisher().recorder
    }
    
    func testStore_whenActionArrived_shouldSendNewState() throws {
        let state = recorder.record(timeout: 1.0) {
            self.sut.send(.initiated)
        }.last
        XCTAssertEqual(state, .afterInitial)
    }
    
    func testStore_whenActionArrived_shouldTriggerSideEffect() throws {
        sut.send(.initiated)
        XCTAssertEqual(sideEffect.triggered!.0, .afterInitial)
        XCTAssertEqual(sideEffect.triggered!.1, .initiated)
    }
    
    func testStore_whenSideEffectEmitsAction_shouldUpdateState() async throws {
        let state = recorder.record(timeout: 1.0, limit: 2) {
            self.sideEffect.send(.sideEffectReceived)
        }.last
        XCTAssertEqual(state, .afterSideEffect)
    }
}
