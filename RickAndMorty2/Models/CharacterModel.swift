//
//  CharacterModel.swift
//  RickAndMorty2
//
//  Created by Pouya Yarandi on 1/14/23.
//

import Foundation

struct CharacterResponseModel: Codable {
    var results: [CharacterModel]
}

struct CharacterModel: Codable {
    var id: Int
    var name: String
    var status: Status
    
    enum Status: String, Codable {
        case alive = "Alive"
        case dead = "Dead"
        case unknown
    }
}
