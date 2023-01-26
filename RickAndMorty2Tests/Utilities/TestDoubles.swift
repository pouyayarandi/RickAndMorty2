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
    
    func reduce(_ state: inout FakeState, with action: FakeAction) -> [SideEffect<FakeAction>] {
        lastReduced = (state, action)
        switch (state, action) {
            
        case (.initial, .initiated):
            state = .afterInitial
            return [Just(.sideEffectReceived).eraseToAnyPublisher()]
            
        case (_, .sideEffectReceived):
            state = .afterSideEffect
            
        default:
            break
        }
        
        return []
    }
}

struct DummyCharactersService: CharactersService {
    func getList() async throws -> [CharacterModel] {
        []
    }
}

struct StubCharacterService: CharactersService {
    var result: Result<[CharacterModel], Error>
    func getList() async throws -> [CharacterModel] {
        return try result.get()
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
