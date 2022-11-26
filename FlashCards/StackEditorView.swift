//
//  StackEditorView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 24.11.22..
//

import SwiftUI

struct StackEditorView: View {
    enum Field: Hashable {
        case newCardFrontText
        case newCardBackText
    }
    
    @Binding var cards: [Card]
    @State private var newCard: Card = Card(frontText: "", backText: "")
    @FocusState private var focusedField: Field?
    
    // TODO: using geometry size for these somehow moves the whole list down initially when it appears in a view with a navigation bar
    private let cardWidth = 150.0
    private let cardHeight = 100.0
    
    var body: some View {
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
                    .background(Color.white)
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
                    .background(Color.white)
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
                .background(Color.white)
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
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                
                Spacer()
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Deck")
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
