//
//  DeckEditorView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 24.11.22..
//

import SwiftUI

struct DeckEditorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var deckBinding: Deck
    @State private var deck: Deck
    private var onSave: () -> Void
    
    @State private var newCard: Card = Card(frontText: "", backText: "")
    
    enum Field: Hashable {
        case newCardFrontText
        case newCardBackText
    }
    @FocusState private var focusedField: Field?
    
    // TODO: using geometry size for these somehow moves the whole list down initially when it appears in a view with a navigation bar
    private let cardWidth = 150.0
    private let cardHeight = 100.0
    
    init(deck: Binding<Deck>, onSave: @escaping () -> Void = {}) {
        self._deckBinding = deck
        self._deck = State(initialValue: deck.wrappedValue)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Deck name", text: $deck.name)
                    .font(.title)
                    .bold()
                    .padding()
                
                List {
                    ForEach($deck.cards) { $card in
                        HStack(spacing: 20) {
                            Spacer()
                            
                            // TODO: use focused state to make touch area span the full card
                            ZStack {
                                TextField("", text: $card.frontText)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 24))
                                    .bold()
                            }
                            .frame(width: self.cardWidth, height: self.cardHeight)
                            .padding()
                            .background(Constants.cardFrontColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            
                            ZStack {
                                TextField("", text: $card.backText)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 24))
                                    .bold()
                            }
                            .frame(width: self.cardWidth, height: self.cardHeight)
                            .padding()
                            .background(Constants.cardBackColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            
                            Spacer()
                        }
                    }
                    .onMove { indexSet, offset in
                        self.deck.cards.move(fromOffsets: indexSet, toOffset: offset)
                    }
                    .onDelete { indexSet in
                        self.deck.cards.remove(atOffsets: indexSet)
                    }
                    
                    HStack(spacing: 20) {
                        Spacer()
                        
                        ZStack {
                            TextField("", text: $newCard.frontText)
                                .onSubmit {
                                    self.focusedField = .newCardBackText
                                }
                                .focused($focusedField, equals: .newCardFrontText)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 24))
                                .bold()
                        }
                        .frame(width: self.cardWidth, height: self.cardHeight)
                        .padding()
                        .background(Constants.cardFrontColor)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        ZStack {
                            TextField("", text: $newCard.backText)
                                .onSubmit {
                                    if !newCard.frontText.isEmpty && !newCard.backText.isEmpty {
                                        self.deck.cards.append(newCard)
                                        newCard = Card(frontText: "", backText: "")
                                        self.focusedField = .newCardFrontText
                                    } else {
                                        self.focusedField = nil
                                    }
                                }
                                .focused($focusedField, equals: .newCardBackText)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 24))
                                .bold()
                        }
                        .frame(width: self.cardWidth, height: self.cardHeight)
                        .padding()
                        .background(Constants.cardBackColor)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        Spacer()
                    }
                }
                .foregroundColor(Color.white)
                .listStyle(PlainListStyle())
            }
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // TODO: sanity checks
                    Button("Save") {
                        self.deckBinding = self.deck
                        self.onSave()
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct DeckEditorView_Previews: PreviewProvider {
    @State private static var deck = Deck(
        name: "tarea #1",
        cards: [
            Card(frontText: "hrana", backText: "comida"),
            Card(frontText: "jabuka", backText: "manzana"),
            Card(frontText: "zena", backText: "mujer")
        ]
    )
    
    static var previews: some View {
        DeckEditorView(deck: $deck)
    }
}
