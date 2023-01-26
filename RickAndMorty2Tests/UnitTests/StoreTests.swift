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
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        reducer = .init()
        sut = .init(reducer: reducer, state: .initial)
        recorder = sut.$state.recorder
    }
    
    func testStore_whenActionArrived_shouldSendNewState() throws {
        let state = recorder.record(timeout: 1.0) {
            self.sut.send(.initiated)
        }.last
        XCTAssertEqual(state, .afterInitial)
    }
    
    func testStore_whenSideEffectEmitsAction_shouldUpdateState() async throws {
        let state = recorder.record(timeout: 1.0, limit: 3) {
            self.sut.send(.initiated)
        }.last
        XCTAssertEqual(state, .afterSideEffect)
    }
}
