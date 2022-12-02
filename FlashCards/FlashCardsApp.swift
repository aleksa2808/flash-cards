//
//  FlashCardsApp.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

@main
struct FlashCardsApp: App {
    @StateObject private var store = DeckStore()
    @State private var isLoaded = false
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if self.isLoaded {
                    ContentView(decks: $store.decks, saveAction: {
                        DeckStore.save(decks: store.decks) { result in
                            if case .failure(let error) = result {
                                fatalError(error.localizedDescription)
                            }
                        }
                    })
                } else {
                    Image("flash_cards")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .onAppear {
                DeckStore.load { result in
                    switch result {
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    case .success(let decks):
                        self.store.decks = decks
                        self.isLoaded = true
                    }
                }
            }
        }
    }
}
