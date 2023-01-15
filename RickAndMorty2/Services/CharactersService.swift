//
//  CharactersService.swift
//  RickAndMorty2
//
//  Created by Pouya Yarandi on 1/14/23.
//

import Foundation

protocol CharactersService {
    func getList() async throws -> [CharacterModel]
}

private struct GetListRequest: Request {
    var path: String {
        "https://rickandmortyapi.com/api/character"
    }
}

class CharacterServiceImpl: CharactersService {
    private var network: Network
    private var decoder: JSONDecoder
    
    init(network: Network) {
        self.network = network
        self.decoder = .init()
    }
    
    func getList() async throws -> [CharacterModel] {
        let data = try await network.fetch(GetListRequest())
        let response = try decoder.decode(CharacterResponseModel.self, from: data)
        return response.results
    }
}
