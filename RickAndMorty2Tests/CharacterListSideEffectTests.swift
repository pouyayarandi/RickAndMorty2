//
//  CharacterListSideEffectTests.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/26/1401 AP.
//

import XCTest
@testable import RickAndMorty2

struct StubCharacterService: CharactersService {
    var result: Result<[CharacterModel], Error>
    func getList() async throws -> [CharacterModel] {
        return try result.get()
    }
}

class CharacterListSideEffectTests: XCTestCase {
    
    var sut: CharacterListSideEffect!
    
    func testSideEffect_whenServiceFinishes_shouldSendLoadedAction() throws {
        sut = CharacterListSideEffect(service: StubCharacterService(result: .success(.fake)))
        
        let action = sut.publisher.recorder.record(timeout: 1.0) {
            self.sut.trigger(state: .loading, action: .refreshTapped)
        }.last
        
        XCTAssertEqual(action, .loadCompleted(.fake))
    }
    
    func testSideEffect_whenServiceFails_shouldSendFailedAction() throws {
        sut = CharacterListSideEffect(service: StubCharacterService(result: .failure(NSError.fake)))
        
        let action = sut.publisher.recorder.record(timeout: 1.0) {
            self.sut.trigger(state: .loading, action: .refreshTapped)
        }.last
        
        XCTAssertEqual(action, .loadFailed(NSError.fake))
    }
}
