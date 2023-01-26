//
//  ContentView.swift
//  RickAndMorty2
//
//  Created by Pouya Yarandi on 1/14/23.
//

import SwiftUI

typealias CharacterListStore = Store<CharacterListState, CharacterListAction>

struct ContentView: View {
    
    @ObservedObject var store: CharacterListStore
    
    var body: some View {
        
        Group {
            switch store.state {
                
            case .initial:
                Text("")
                
            case .loading:
                Text("Loading...")
                
            case .loaded(date: let data):
                CharacterListView(data: data)
                    .environmentObject(store)
                
            case .failed(error: let error):
                ErrorBlockingView(error: error)
                    .environmentObject(store)
            }
        }
        .onAppear {
            store.send(.initiated)
        }
    }
}

struct CharacterListView: View {
    var data: CharacterListState.LoadedStateData
    @EnvironmentObject var store: CharacterListStore
    
    var body: some View {
        NavigationView {
            VStack {
                List(data.list, id: \.id) { item in
                    CharacterCell(item: item)
                }
                .listStyle(PlainListStyle())
                
                Button("Refresh") {
                    store.send(.refreshTapped)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .navigationBarTitle("List", displayMode: .inline)
        }
    }
}

struct CharacterCell: View {
    var item: CharacterModel
    
    var body: some View {
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
}

struct ErrorBlockingView: View {
    var error: Error
    @EnvironmentObject var store: CharacterListStore
    
    var body: some View {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let service = CharacterServiceImpl(network: NetworkLayer(session: .shared))
        let reducer = CharacterListReducer(service: service)
        return Group {
            ContentView(store: .init(reducer: reducer, state: .loaded(date: .init(list: [.init(id: 0, name: "Rick", status: .alive)]))))
            
            ContentView(store: .init(reducer: reducer, state: .failed(error: NSError(domain: "some error", code: 1))))
        }
    }
}
