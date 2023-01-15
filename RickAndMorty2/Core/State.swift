//
//  State.swift
//  RickAndMorty2
//
//  Created by Pouya Yarandi on 1/14/23.
//

import Foundation
import SwiftUI
import Combine

protocol State {}

protocol Action {}

protocol SideEffect<S, A> {
    associatedtype S: State
    associatedtype A: Action
    var publisher: AnyPublisher<A, Never> { get }
    func trigger(state: S, action: A)
}

protocol Reducer<S, A> {
    associatedtype S: State
    associatedtype A: Action
    var sideEffect: (any SideEffect<S, A>) { get }
    func reduce(_ state: S, with action: A) -> S
}

extension Reducer {
    var sideEffect: (any SideEffect<S, A>) { NoSideEffect() }
}

struct NoSideEffect<S: State, A: Action>: SideEffect {
    func trigger(state: S, action: A) {}
    var publisher: AnyPublisher<A, Never> {
        Empty().eraseToAnyPublisher()
    }
}

class Store<S: State, A: Action>: ObservableObject {
    private var reducer: any Reducer<S, A>
    private var store = Set<AnyCancellable>()
    
    @Published var state: S
    
    init(reducer: any Reducer<S, A>, state: S) {
        self.reducer = reducer
        self.state = state
        
        reducer
            .sideEffect
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &store)
    }
    
    func send(_ action: A) {
        state = reducer.reduce(state, with: action)
        reducer.sideEffect.trigger(state: state, action: action)
    }
}
