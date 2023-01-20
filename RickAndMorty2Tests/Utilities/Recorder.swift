//
//  Recorder.swift
//  RickAndMorty2Tests
//
//  Created by Pouya on 10/25/1401 AP.
//

import Foundation
import Combine
import XCTest

class Recorder<T, E: Error> {
    
    private var publisher: AnyPublisher<T, E>
    private var waiter: XCTWaiter
    
    private var records: [T] = []
    private var expectation = XCTestExpectation()
    private var cancellables = Set<AnyCancellable>()
    
    init(publisher: AnyPublisher<T, E>) {
        self.publisher = publisher
        self.waiter = .init()
    }
    
    func record(timeout: TimeInterval, limit: Int = 1, _ block: (() -> Void)? = nil) -> [T] {
        defer { records.removeAll() }
        
        publisher.sink(receiveCompletion: { _ in }) { value in
            self.records.append(value)
            
            if self.records.count >= limit {
                self.expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        block?()
        
        waiter.wait(for: [expectation], timeout: timeout)
        return records
    }
}

extension AnyPublisher {
    var recorder: Recorder<Output, Failure> {
        .init(publisher: self)
    }
}
