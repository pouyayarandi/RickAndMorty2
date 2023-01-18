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
        let data: [CharacterModel] = [.init(id: 0, name: "Test", status: .alive)]
        sut = CharacterListSideEffect(service: StubCharacterService(result: .success(data)))
        let recorder = sut.publisher.record(on: self)
        
        recorder.record(timeout: 1.0) {
            self.sut.trigger(state: .loading, action: .refreshTapped)
        }
        
        guard case .loadCompleted(data) = recorder.lastRecordedValue else {
            XCTFail()
            return
        }
    }
    
    func testSideEffect_whenServiceFails_shouldSendFailedAction() throws {
        let error = NSError(domain: "error", code: -1)
        sut = CharacterListSideEffect(service: StubCharacterService(result: .failure(error)))
        let recorder = sut.publisher.record(on: self)
        
        recorder.record(timeout: 1.0) {
            self.sut.trigger(state: .loading, action: .refreshTapped)
        }
        
        if case .loadFailed(let e) = recorder.lastRecordedValue {
            XCTAssertEqual(e.localizedDescription, error.localizedDescription)
        } else {
            XCTFail()
        }
    }
}
