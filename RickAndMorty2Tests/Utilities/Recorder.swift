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
    weak private var testcase: XCTestCase?
    
    private(set) var lastRecordedValue: T?
    
    private var expectation = XCTestExpectation()
    private var cancellables = Set<AnyCancellable>()
    
    init(publisher: AnyPublisher<T, E>, testcase: XCTestCase) {
        self.publisher = publisher
        self.testcase = testcase
    }
    
    func record(timeout: TimeInterval, limit: Int = 1, _ block: (() -> Void)? = nil) {
        var records = 0
        
        publisher.sink(receiveCompletion: { _ in }) { value in
            self.lastRecordedValue = value
            records += 1
            
            if records == limit {
                self.expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        block?()
        
        testcase?.wait(for: [expectation], timeout: timeout)
    }
}

extension AnyPublisher {
    func record(on testcase: XCTestCase) -> Recorder<Output, Failure> {
        .init(publisher: self, testcase: testcase)
    }
}
