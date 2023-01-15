//
//  CharacterListReducer.swift
//  RickAndMorty2
//
//  Created by Pouya Yarandi on 1/14/23.
//

import Foundation
import Combine

enum CharacterListState: State {
    case initial
    case loading
    case loaded(date: LoadedStateData)
    case failed(error: Error)
    
    struct LoadedStateData {
        var list: [CharacterModel]
    }
}

enum CharacterListAction: Action {
    case initiated
    case loadCompleted(_ data: [CharacterModel])
    case loadFailed(_ error: Error)
    case refreshTapped
}

struct CharacterListSideEffect: SideEffect {
    private var service: CharactersService
    private var action: PassthroughSubject<CharacterListAction, Never>
    
    init(service: CharactersService) {
        self.service = service
        self.action = .init()
    }
    
    var publisher: AnyPublisher<CharacterListAction, Never> {
        action.eraseToAnyPublisher()
    }
    
    func trigger(state: CharacterListState, action: CharacterListAction) {
        guard case .loading = state else { return }
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            do {
                let list = try await service.getList()
                self.action.send(.loadCompleted(list))
            } catch {
                self.action.send(.loadFailed(error))
            }
        }
    }
}

struct CharacterListReducer: Reducer {
    var sideEffect: any SideEffect<CharacterListState, CharacterListAction>
    
    init(sideEffect: any SideEffect<CharacterListState, CharacterListAction>) {
        self.sideEffect = sideEffect
    }
    
    func reduce(_ state: CharacterListState, with action: CharacterListAction) -> CharacterListState {
        switch (state, action) {
            
        case (.initial, .initiated):
            return .loading
            
        case (.loading, .loadCompleted(let list)):
            return .loaded(date: .init(list: list))
            
        case (.loading, .loadFailed(let error)):
            return .failed(error: error)
            
        case (.loaded, .refreshTapped):
            return .loading
            
        default:
            return state
        }
    }
}
