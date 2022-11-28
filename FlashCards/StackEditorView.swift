//
//  StackEditorView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 24.11.22..
//

import SwiftUI

struct StackEditorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var cardsBinding: [Card]
    @State private var cards: [Card]
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
    
    init(cards: Binding<[Card]>, onSave: @escaping () -> Void = {}) {
        self._cardsBinding = cards
        self._cards = State(initialValue: cards.wrappedValue)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach($cards) { $card in
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
                    cards.move(fromOffsets: indexSet, toOffset: offset)
                }
                .onDelete { indexSet in
                    cards.remove(atOffsets: indexSet)
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
                                    self.cards.append(newCard)
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
            .listStyle(PlainListStyle())
            .interactiveDismissDisabled()
            .navigationTitle("Deck editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: sanity checks
                        
                        self.cardsBinding = self.cards
                        self.onSave()
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct StackEditorView_Previews: PreviewProvider {
    @State static var cards = [
        Card(frontText: "skola", backText: "escuela"),
        Card(frontText: "rec", backText: "palabra"),
        Card(frontText: "hrana", backText: "comida"),
    ]
    
    static var previews: some View {
        StackEditorView(cards: $cards)
    }
}
