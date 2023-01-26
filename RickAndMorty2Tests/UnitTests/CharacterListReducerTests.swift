//
//  CharacterListReducerTests.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/26/1401 AP.
//

import XCTest
@testable import RickAndMorty2

final class CharacterListReducerTests: XCTestCase {

    var state: CharacterListState!
    var sut: CharacterListReducer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = .init(service: DummyCharactersService())
    }

    func testReducer_whenIsInitiated_shouldStartLoading() throws {
        state = .initial
        _ = sut.reduce(&state, with: .initiated)
        XCTAssertEqual(state, .loading)
    }
    
    func testReducer_whenIsLoadingAndLoadFinishes_shouldChangeToLoaded() throws {
        state = .loading
        _ = sut.reduce(&state, with: .loadCompleted(.fake))
        XCTAssertEqual(state, .loaded(date: .init(list: .fake)))
    }
    
    func testReducer_whenIsLoadingAndLoadFails_shouldChangeToFailed() throws {
        state = .loading
        _ = sut.reduce(&state, with: .loadFailed(NSError.fake))
        XCTAssertEqual(state, .failed(error: NSError.fake))
    }
    
    func testReducer_whenIsLoadedAndRefreshes_shouldGoToLoading() throws {
        state = .loaded(date: .init(list: []))
        _ = sut.reduce(&state, with: .refreshTapped)
        XCTAssertEqual(state, .loading)
    }
    
    func testReducer_whenIsFailedAndRefreshes_shouldGoToLoading() throws {
        state = .failed(error: NSError.fake)
        _ = sut.reduce(&state, with: .refreshTapped)
        XCTAssertEqual(state, .loading)
    }
    
    func testReducer_whenLoadingCancels_shouldShowLatestResults() throws {
        state = .loading
        _ = sut.reduce(&state, with: .loadCompleted(.fake))
        _ = sut.reduce(&state, with: .refreshTapped)
        _ = sut.reduce(&state, with: .cancelLoading)
        XCTAssertEqual(state, .loaded(date: .init(list: .fake)))
    }
}
