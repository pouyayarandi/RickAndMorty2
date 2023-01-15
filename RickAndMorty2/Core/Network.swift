//
//  Network.swift
//  RickAndMorty2
//
//  Created by Pouya Yarandi on 1/14/23.
//

import Foundation

protocol Request {
    var path: String { get }
}

extension Request {
    var url: URL? {
        .init(string: path)
    }
    
    var request: URLRequest? {
        guard let url else { return nil }
        return .init(url: url)
    }
}

protocol Network {
    func fetch<R: Request>(_ request: R) async throws -> Data
}

class NetworkLayer: Network {
    private var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func fetch<R>(_ request: R) async throws -> Data where R : Request {
        guard let request = request.request else {
            throw NSError(domain: "no_request", code: -1)
        }
        return try await session.data(for: request).0
    }
}
