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

typealias SideEffect<A: Action> = AnyPublisher<A, Never>

protocol Reducer<S, A> {
    associatedtype S: State
    associatedtype A: Action
    func reduce(_ state: inout S, with action: A) -> [SideEffect<A>]
}

class Store<S: State, A: Action>: ObservableObject {
    private var reducer: any Reducer<S, A>
    private var store = Set<AnyCancellable>()
    
    @Published private(set) var state: S
    
    init(reducer: any Reducer<S, A>, state: S) {
        self.reducer = reducer
        self.state = state
    }
    
    func send(_ action: A) {
        let sideEffects = reducer.reduce(&state, with: action)
        
        for sideEffect in sideEffects {
            sideEffect
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: send)
                .store(in: &store)
        }
    }
}
