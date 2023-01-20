//
//  Extensions.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/30/1401 AP.
//

import Foundation
@testable import RickAndMorty2

extension CharacterModel: Equatable {
    public static func == (lhs: CharacterModel, rhs: CharacterModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension CharacterListState: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial), (.loading, .loading):
            return true
        case (.loaded(let l), .loaded(let r)):
            return l.list == r.list
        case (.failed(let l), .failed(let r)):
            return l.localizedDescription == r.localizedDescription
        default:
            return false
        }
    }
}

extension CharacterListAction: Equatable {
    public static func == (lhs: CharacterListAction, rhs: CharacterListAction) -> Bool {
        switch (lhs, rhs) {
        case (.initiated, .initiated), (.refreshTapped, .refreshTapped):
            return true
        case (.loadCompleted(let l), .loadCompleted(let r)):
            return l == r
        case (.loadFailed(let l), .loadFailed(let r)):
            return l.localizedDescription == r.localizedDescription
        default:
            return false
        }
    }
}
