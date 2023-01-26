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
    case cancelLoading
}

class CharacterListReducer: Reducer {
    var service: CharactersService
    private var lastState: CharacterListState?
    private var task: Task<Void, Never>?
    
    init(service: CharactersService) {
        self.service = service
    }
    
    func reduce(_ state: inout CharacterListState, with action: CharacterListAction) -> [SideEffect<CharacterListAction>] {
        if case .loaded = state {
            lastState = state
        }
        
        switch (state, action) {
            
        case (.initial, .initiated):
            state = .loading
            return [loadDataSideEffect]
            
        case (.loading, .loadCompleted(let list)):
            state = .loaded(date: .init(list: list))
            
        case (.loading, .loadFailed(let error)):
            state = .failed(error: error)
            
        case (.loaded, .refreshTapped):
            state = .loading
            return [loadDataSideEffect]
            
        case (.failed, .refreshTapped):
            state = .loading
            return [loadDataSideEffect]
            
        case (.loading, .cancelLoading):
            cancelLoading()
            if let lastState {
                state = lastState
            }
            
        default:
            break
        }
        
        return []
    }
}

extension CharacterListReducer {
    private var loadDataSideEffect: SideEffect<CharacterListAction> {
        Future(loadData).eraseToAnyPublisher()
    }
    
    private func loadData(_ promise: @escaping Future<CharacterListAction, Never>.Promise) {
        task?.cancel()
        task = Task {
            do {
                let list = try await service.getList()
                promise(.success(.loadCompleted(list)))
            } catch {
                promise(.success(.loadFailed(error)))
            }
        }
    }
    
    private func cancelLoading() {
        task?.cancel()
    }
}
