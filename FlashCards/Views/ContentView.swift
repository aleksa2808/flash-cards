//
//  ContentView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

struct ContentView: View {
    @Binding var decks: [Deck]
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: ()->Void
    
    @State private var draftDeck: Deck = Deck(name: "", cards: [])
    @State private var showDeckEditor = false
    
    @State private var selectionMode = false
    @State private var selectedDecks = Set<Deck>()
    @State private var showCombinedDeckTestView = false
    
    init(decks: Binding<[Deck]>, saveAction: @escaping ()->Void) {
        self._decks = decks
        self.saveAction = saveAction
    }
    
    private func mergeDecks(name: String, decks: Set<Deck>) -> Deck {
        // TODO: deduplicate cards even if they don't have the same ID
        // TODO: see if preserving card order makes sense
        var cards = Set<Card>()
        for deck in self.selectedDecks {
            cards.formUnion(deck.cards)
        }
        
        return Deck(name: name, cards: Array(cards))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // TODO: deck editing should somehow be disabled here
                NavigationLink(destination: TestView(deck: $draftDeck), isActive: $showCombinedDeckTestView) { EmptyView() }
                
                List {
                    ForEach($decks) { $deck in
                        if !self.selectionMode {
                            NavigationLink(destination: TestView(deck: $deck)) {
                                HStack {
                                    Text(deck.name)
                                    Text("(" + String(deck.cards.count) + ")").foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding()
                            }
                        } else {
                            Button(action: {
                                if !self.selectedDecks.insert(deck).inserted {
                                    self.selectedDecks.remove(deck)
                                }
                            }) {
                                HStack {
                                    if self.selectedDecks.contains(deck) {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                                    } else {
                                        Image(systemName: "circle").foregroundColor(.gray)
                                    }
                                    Text(deck.name)
                                    Text("(" + String(deck.cards.count) + ")").foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                    }
                    .onMove { indexSet, offset in
                        self.decks.move(fromOffsets: indexSet, toOffset: offset)
                    }
                    .onDelete { indexSet in
                        self.decks.remove(atOffsets: indexSet)
                    }
                    
                    if !self.selectionMode {
                        Button(action: {
                            self.draftDeck = Deck(name: "", cards: [])
                            self.showDeckEditor = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add deck")
                            }
                            .foregroundColor(.blue)
                            .padding()
                        }
                    }
                }
                .font(.system(size: 24))
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !self.selectionMode {
                        Button(action: {
                            self.selectionMode = true
                        }) {
                            Text("Select")
                        }
                    } else {
                        Button(action: {
                            self.selectionMode = false
                            self.selectedDecks.removeAll()
                        }) {
                            Text("Done").bold()
                        }
                    }
                }
                
                if self.selectionMode && self.selectedDecks.count > 1 {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: {
                            self.draftDeck = self.mergeDecks(name: "Combined deck", decks: self.selectedDecks)
                            
                            self.selectionMode = false
                            self.selectedDecks.removeAll()
                            
                            self.showCombinedDeckTestView = true
                        }) {
                            Text("Run combined deck")
                        }
                        
                        Button(action: {
                            self.draftDeck = self.mergeDecks(name: "", decks: self.selectedDecks)
                            
                            self.selectionMode = false
                            self.selectedDecks.removeAll()
                            
                            self.showDeckEditor = true
                        }) {
                            Text("Merge into new deck")
                        }
                    }
                }
            }
            .navigationTitle("Decks")
        }
        .sheet(isPresented: $showDeckEditor) {
            DeckEditorView(initialDeckState: draftDeck, onSave: { deck in
                self.decks.append(deck)
            })
        }
        .onChange(of: self.scenePhase) { phase in
            if phase == .inactive {
                self.saveAction()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @State private static var decks = [
        Deck(
            name: "tarea #1",
            cards: [
                Card(frontText: "hrana", backText: "comida"),
                Card(frontText: "jabuka", backText: "manzana"),
                Card(frontText: "zena", backText: "mujer")
            ]
        ),
        Deck(
            name: "tarea #2",
            cards: [
                Card(frontText: "leto", backText: "verano"),
                Card(frontText: "zima", backText: "invierno")
            ]
        )
    ]
    
    static var previews: some View {
        ContentView(decks: $decks, saveAction: {})
    }
}
