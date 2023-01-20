//
//  CharacterListTests.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/30/1401 AP.
//

import XCTest
@testable import RickAndMorty2

final class CharacterListTests: XCTestCase {
    
    var store: Store<CharacterListState, CharacterListAction>!
    var reducer: CharacterListReducer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let service = StubCharacterService(result: .success(.fake))
        let sideEffect = CharacterListSideEffect(service: service)
        reducer = CharacterListReducer(sideEffect: sideEffect)
    }

    func testCharacterList_whenInitiated_shouldReceiveList() throws {
        store = .init(reducer: reducer, state: .initial)
        
        let state = store.$state
            .eraseToAnyPublisher()
            .recorder
            .record(timeout: 1.0, limit: 3) {
                self.store.send(.initiated)
            }
            .last
        
        XCTAssertEqual(state, .loaded(date: .init(list: .fake)))
    }
    
    func testCharacterList_whenRefreshesInFailure_shouldReceiveList() throws {
        store = .init(reducer: reducer, state: .failed(error: NSError.fake))
        
        let state = store.$state
            .eraseToAnyPublisher()
            .recorder
            .record(timeout: 1.0, limit: 3) {
                self.store.send(.refreshTapped)
            }
            .last
        
        XCTAssertEqual(state, .loaded(date: .init(list: .fake)))
    }
}
