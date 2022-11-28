//
//  ContentView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

struct Card: Identifiable {
    let id: UUID = UUID()
    var frontText: String
    var backText: String
}

func createCardIDSets(cards: [Card]) -> [[Int]] {
    let numOfStages = 4
    
    var cardIDSets: [[Int]] = []
    
    var cardIDSet: [Int] = []
    for i in 0 ..< cards.count {
        cardIDSet.append(i)
    }
    cardIDSets.append(cardIDSet.shuffled())
    
    for _ in 1 ..< numOfStages {
        cardIDSets.append([])
    }
    
    return cardIDSets
}

struct DeckState {
    var cardIDSets: [[Int]]
    var currentStage: Int
    var cardsLearned: Int
    
    mutating func reset(cards: [Card]) {
        self.cardIDSets = createCardIDSets(cards: cards)
        self.currentStage = 0
        self.cardsLearned = 0
    }
}

// TODO: remove after testing
let initialCards = [
    Card(frontText: "hrana", backText: "comida"),
    Card(frontText: "jabuka", backText: "manzana"),
    Card(frontText: "zena", backText: "mujer")
]

struct ContentView: View {
    @State private var cards: [Card] = initialCards
    @State private var deckState = DeckState(
        cardIDSets: createCardIDSets(cards: initialCards),
        currentStage: 0,
        cardsLearned: 0
    )
    @State private var deckIteration = 0
    @State private var deckFlipped = false
    @State private var swipeCount: Int = 0
    @State private var showEditor = false
    
    private func getCardOffset(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return CGFloat(position) * -10
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return geometry.size.width + getCardOffset(geometry, position: position)
    }
    
    private func resetDeck() {
        deckState.reset(cards: self.cards)
        deckIteration += 1
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(gradient: Gradient(colors: [Color.init(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color.init(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))]), startPoint: .bottom, endPoint: .top)
                    .frame(width: geometry.size.width * 1.5, height: geometry.size.height)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .offset(x: -geometry.size.width / 4, y: -geometry.size.height / 2)
                
                VStack(spacing: 24) {
                    VStack(spacing: 0) {
                        Text("Progress")
                            .font(.title)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing:0) {
                            ForEach(Array(self.deckState.cardIDSets.map{$0.count}.enumerated()), id: \.0) { stage, cardsInStage in
                                if self.deckState.cardsLearned != self.cards.count && stage == self.deckState.currentStage {
                                    ZStack {
                                        Text(String(cardsInStage))
                                            .font(.title)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .top)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(Color.yellow, lineWidth: 5)
                                            )
                                    }
                                } else {
                                    // TODO: any way to do conditional modifiers?
                                    Text(String(cardsInStage))
                                        .font(.title)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .top)
                                }
                            }
                            if self.deckState.cardsLearned == self.cards.count && !self.cards.isEmpty {
                                Text(String(self.deckState.cardsLearned))
                                    .font(.title)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .top)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.green, lineWidth: 5)
                                    )
                            } else {
                                Text(String(self.deckState.cardsLearned))
                                    .font(.title)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .top)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    
                    Spacer()
                    
                    if self.deckState.cardsLearned == self.cards.count {
                        if !self.cards.isEmpty {
                            Text("Deck learned!")
                                .font(.title)
                                .bold()
                                .foregroundColor(.green)
                        } else {
                            Text("Deck empty!")
                                .font(.title)
                                .bold()
                                .foregroundColor(.yellow)
                        }
                    } else {
                        ZStack {
                            ForEach(Array(self.deckState.cardIDSets[self.deckState.currentStage].prefix(4).enumerated().reversed()), id: \.element) { i, cardID in
                                let card = self.cards[cardID]
                                CardView(card: card, frontFacing: !self.deckFlipped, showText: i == 0, onRemove: { correct in
                                    // TODO: simplify
                                    
                                    // only purpose is to update animations. is there a better way?
                                    self.swipeCount += 1
                                    
                                    let removedCardID = self.deckState.cardIDSets[self.deckState.currentStage].remove(at: 0)
                                    if correct {
                                        if self.deckState.currentStage == self.deckState.cardIDSets.count - 1 {
                                            self.deckState.cardsLearned += 1
                                        } else {
                                            self.deckState.cardIDSets[self.deckState.currentStage + 1].append(removedCardID)
                                        }
                                    } else if self.deckState.currentStage > 0 {
                                        self.deckState.cardIDSets[self.deckState.currentStage - 1].append(removedCardID)
                                    } else {
                                        self.deckState.cardIDSets[self.deckState.currentStage].append(removedCardID)
                                    }
                                    
                                    if self.deckState.cardIDSets[self.deckState.currentStage].isEmpty {
                                        if self.deckState.currentStage > 0 && !self.deckState.cardIDSets[self.deckState.currentStage - 1].isEmpty {
                                            self.deckState.currentStage -= 1
                                            self.deckState.cardIDSets[self.deckState.currentStage] = self.deckState.cardIDSets[self.deckState.currentStage].shuffled()
                                        } else if self.deckState.currentStage < self.deckState.cardIDSets.count - 1 {
                                            self.deckState.currentStage += 1
                                            self.deckState.cardIDSets[self.deckState.currentStage] = self.deckState.cardIDSets[self.deckState.currentStage].shuffled()
                                        }
                                    }
                                })
                                .animation(.spring(), value: self.swipeCount)
                                .frame(width: self.getCardWidth(geometry, position: i), height: geometry.size.height / 2)
                                .offset(x: 0, y: self.getCardOffset(geometry, position: i))
                            }
                        }
                        .id(self.deckIteration)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            self.showEditor.toggle()
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 42))
                                .bold()
                                .padding()
                                .cornerRadius(40)
                                .foregroundColor(.blue)
                                .padding(10)
                        }
                        Button(action: {
                            self.resetDeck()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 42))
                                .bold()
                                .padding()
                                .cornerRadius(40)
                                .foregroundColor(.blue)
                                .padding(10)
                        }
                        Button(action: {
                            self.resetDeck()
                            self.deckFlipped.toggle()
                        }) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 42))
                                .bold()
                                .padding()
                                .cornerRadius(40)
                                .foregroundColor(.blue)
                                .padding(10)
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showEditor) {
            StackEditorView(cards: $cards, onSave: resetDeck)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
