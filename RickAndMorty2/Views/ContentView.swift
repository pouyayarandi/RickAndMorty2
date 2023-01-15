//
//  ContentView.swift
//  RickAndMorty2
//
//  Created by Pouya Yarandi on 1/14/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store: Store<CharacterListState, CharacterListAction>
    
    var body: some View {
        
        Group {
            switch store.state {
                
            case .initial:
                Text("")
                
            case .loading:
                Text("Loading...")
                
            case .loaded(date: let data):
                VStack {
                    List(data.list, id: \.id) { item in
                        VStack {
                            HStack {
                                Text(item.name)
                                Spacer()
                            }
                            HStack {
                                Text(item.status.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    Button("Refresh") {
                        store.send(.refreshTapped)
                    }
                    .padding()
                }
                
            case .failed(error: let error):
                VStack {
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                    
                    Button("Refresh") {
                        store.send(.refreshTapped)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            store.send(.initiated)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let service = CharacterServiceImpl(network: NetworkLayer(session: .shared))
        let sideEffect = CharacterListSideEffect(service: service)
        let reducer = CharacterListReducer(sideEffect: sideEffect)
        return Group {
            ContentView(store: .init(reducer: reducer, state: .loaded(date: .init(list: [.init(id: 0, name: "Rick", status: .alive)]))))
            
            ContentView(store: .init(reducer: reducer, state: .failed(error: NSError(domain: "some error", code: 1))))
        }
    }
}
