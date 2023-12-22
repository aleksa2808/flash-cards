//
//  DeckEditorView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 24.11.22..
//

import SwiftUI

struct DeckEditorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showAlert: Bool = false
    @State private var errorMessage = ""
    
    @State private var deck: Deck
    private var onSave: (Deck) -> Void
    
    @State private var newCard: Card = Card(frontText: "", backText: "")
    
    enum Field: Hashable {
        case newCardFrontText
        case newCardBackText
    }
    @FocusState private var focusedField: Field?
    
    // TODO: using geometry size for these somehow moves the whole list down initially when it appears in a view with a navigation bar
    private let cardWidth = 150.0
    private let cardHeight = 100.0
    
    @Environment(\.colorScheme) private var colorScheme
    private var cardFrontColor: Color {
        self.colorScheme == .light ? LightModeColors.cardFrontColor : DarkModeColors.cardFrontColor
    }
    private var cardBackColor: Color {
        self.colorScheme == .light ? LightModeColors.cardBackColor : DarkModeColors.cardBackColor
    }
    
    init(initialDeckState: Deck, onSave: @escaping (Deck) -> Void) {
        self._deck = State(initialValue: initialDeckState)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Deck name", text: $deck.name)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
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
                            .background(self.cardFrontColor)
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
                            .background(self.cardBackColor)
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
                        .background(self.cardFrontColor)
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
                        .background(self.cardBackColor)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        Spacer()
                    }
                }
                .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                .listStyle(PlainListStyle())
            }
            .alert(self.errorMessage, isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}
            })
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: more sanity checks
                        if self.deck.name.isEmpty {
                            self.errorMessage = "No deck name provided"
                            self.showAlert = true
                        } else if self.deck.cards.isEmpty {
                            self.errorMessage = "Decks cannot be empty"
                            self.showAlert = true
                        } else if self.deck.cards.contains(where: { card in
                            card.frontText.trimmingCharacters(in: .whitespaces).isEmpty || card.backText.trimmingCharacters(in: .whitespaces).isEmpty
                        }) {
                            self.errorMessage = "Card text cannot be empty"
                            self.showAlert = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                            self.onSave(self.deck)
                        }
                    }
                }
            }
        }
    }
}

struct DeckEditorView_Previews: PreviewProvider {
    private static var deck = Deck(
        name: "tarea #1",
        cards: [
            Card(frontText: "hrana", backText: "comida"),
            Card(frontText: "jabuka", backText: "manzana"),
            Card(frontText: "zena", backText: "mujer")
        ]
    )
    
    static var previews: some View {
        DeckEditorView(initialDeckState: deck, onSave: { _ in })
    }
}
