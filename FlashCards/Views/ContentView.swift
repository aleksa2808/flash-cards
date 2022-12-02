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
    
    @State private var presentNewDeckNameForm = false
    @State private var newDeckName = ""
    @State private var showDeckEditor = false
    
    init(decks: Binding<[Deck]>, saveAction: @escaping ()->Void) {
        self._decks = decks
        self.saveAction = saveAction
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($decks) { $deck in
                        NavigationLink(destination: TestView(deck: $deck)) {
                            HStack {
                                Text(deck.name)
                                Text("(" + String(deck.cards.count) + ")").foregroundColor(.gray)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .onMove { indexSet, offset in
                        self.decks.move(fromOffsets: indexSet, toOffset: offset)
                    }
                    .onDelete { indexSet in
                        self.decks.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: {
                        self.presentNewDeckNameForm = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add deck")
                        }
                        .foregroundColor(.blue)
                        .padding()
                    }
                    .alert("Enter deck name", isPresented: $presentNewDeckNameForm, actions: {
                        TextField("Name", text: $newDeckName)
                        
                        // TODO: ideally we would disable the button if the textfield is empty or has the same name as an existing deck, but currently that just makes the button not show up
                        Button("Create", action: {
                            self.decks.append(Deck(name: !self.newDeckName.isEmpty ? self.newDeckName : "Untitled deck", cards: []))
                            self.newDeckName = ""
                            self.showDeckEditor = true
                        })
                        Button("Cancel", role: .cancel, action: {})
                    })
                }
                .font(.system(size: 24))
                .listStyle(.plain)
            }
            .navigationTitle("Decks")
        }
        .sheet(isPresented: $showDeckEditor) {
            DeckEditorView(deck: $decks.last!)
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
