//
//  CharacterListReducerTests.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/26/1401 AP.
//

import XCTest
@testable import RickAndMorty2

final class CharacterListReducerTests: XCTestCase {

    var sut: CharacterListReducer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = .init(sideEffect: NoSideEffect())
    }

    func testReducer_whenIsInitiated_shouldStartLoading() throws {
        let newState = sut.reduce(.initial, with: .initiated)
        XCTAssertEqual(newState, .loading)
    }
    
    func testReducer_whenIsLoadingAndLoadFinishes_shouldChangeToLoaded() throws {
        let newState = sut.reduce(.loading, with: .loadCompleted(.fake))
        XCTAssertEqual(newState, .loaded(date: .init(list: .fake)))
    }
    
    func testReducer_whenIsLoadingAndLoadFails_shouldChangeToFailed() throws {
        let newState = sut.reduce(.loading, with: .loadFailed(NSError.fake))
        XCTAssertEqual(newState, .failed(error: NSError.fake))
    }
    
    func testReducer_whenIsLoadedAndRefreshes_shouldGoToLoading() throws {
        let newState = sut.reduce(.loaded(date: .init(list: [])), with: .refreshTapped)
        XCTAssertEqual(newState, .loading)
    }
    
    func testReducer_whenIsFailedAndRefreshes_shouldGoToLoading() throws {
        let newState = sut.reduce(.failed(error: NSError.fake), with: .refreshTapped)
        XCTAssertEqual(newState, .loading)
    }
}
