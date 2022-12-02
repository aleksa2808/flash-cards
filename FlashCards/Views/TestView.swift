//
//  TestView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 28.11.22..
//

import SwiftUI

func createCardSets(cards: [Card]) -> [[Card]] {
    let numOfStages = 4
    var cardSets: [[Card]] = []
    
    cardSets.append(cards.shuffled())
    for _ in 1 ..< numOfStages {
        cardSets.append([])
    }
    
    return cardSets
}

struct TestState {
    var cardSets: [[Card]]
    var currentStage: Int
    var cardsLearned: Int
    var iteration = 0
    
    mutating func reset(cards: [Card]) {
        self.cardSets = createCardSets(cards: cards)
        self.currentStage = 0
        self.cardsLearned = 0
        self.iteration += 1
    }
    
    mutating func onRemoveCard(correct: Bool) {
        let removedCard = self.cardSets[self.currentStage].remove(at: 0)
        if correct {
            // if we're in the last stage ...
            if self.currentStage == self.cardSets.count - 1 {
                // ... then mark the card as learned
                self.cardsLearned += 1
            } else {
                // ... else move it to the next stage
                self.cardSets[self.currentStage + 1].append(removedCard)
            }
        } else if self.currentStage > 0 {
            // if we're not in the first stage then move it to the previous stage ...
            self.cardSets[self.currentStage - 1].append(removedCard)
        } else {
            // ... else move it to the current stage's back
            self.cardSets[self.currentStage].append(removedCard)
        }
        
        // if the current stage is finished ...
        if self.cardSets[self.currentStage].isEmpty {
            // ... and there are cards in the previous set ...
            if self.currentStage > 0 && !self.cardSets[self.currentStage - 1].isEmpty {
                // ... then move to the previous stage ...
                self.currentStage -= 1
                self.cardSets[self.currentStage].shuffle()
            } else if self.currentStage < self.cardSets.count - 1 {
                // ... else if we're not in the last stage, move to the next stage
                self.currentStage += 1
                self.cardSets[self.currentStage].shuffle()
            }
        }
    }
    
}

struct TestView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var deck: Deck
    
    @State private var testState: TestState
    @State private var cardsStartFlipped = false
    @State private var swipeCount: Int = 0
    @State private var showDeckEditor = false
    
    @Environment(\.colorScheme) var colorScheme
    private var gradientColors: [Color] {
        let colors = [Color.init(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color.init(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))]
        return self.colorScheme == .light ? colors : colors.reversed()
    }
    
    init(deck: Binding<Deck>) {
        self._deck = deck
        self._testState = State(initialValue: TestState(
            cardSets: createCardSets(cards: deck.wrappedValue.cards),
            currentStage: 0,
            cardsLearned: 0
        ))
    }
    
    private func getCardOffset(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return CGFloat(position) * -10
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return geometry.size.width + getCardOffset(geometry, position: position)
    }
    
    private func resetTest() {
        self.testState.reset(cards: self.deck.cards)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(gradient: Gradient(colors: self.gradientColors), startPoint: .bottom, endPoint: .top)
                    .frame(width: geometry.size.width * 1.5, height: geometry.size.height)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .offset(x: -geometry.size.width / 4, y: -geometry.size.height / 2)
                
                VStack(spacing: 24) {
                    TestProgressView(
                        title: self.deck.name,
                        testState: self.testState
                    )
                    
                    Spacer()
                    
                    if self.testState.cardsLearned == self.deck.cards.count {
                        if !self.deck.cards.isEmpty {
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
                            ForEach(Array(self.testState.cardSets[self.testState.currentStage].prefix(4).enumerated().reversed()), id: \.element) { i, card in
                                CardView(card: card, startFlipped: self.cardsStartFlipped, showText: i == 0, onRemove: { self.testState.onRemoveCard(correct: $0) })
                                    .animation(.spring(), value: self.testState.cardSets)
                                    .frame(width: self.getCardWidth(geometry, position: i), height: geometry.size.height / 2)
                                    .offset(x: 0, y: self.getCardOffset(geometry, position: i))
                            }
                        }
                        .id(self.testState.iteration)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 42))
                                .bold()
                                .padding()
                                .cornerRadius(40)
                                .foregroundColor(.blue)
                                .padding(5)
                        }
                        Button(action: {
                            self.showDeckEditor.toggle()
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 42))
                                .bold()
                                .padding()
                                .cornerRadius(40)
                                .foregroundColor(.blue)
                                .padding(5)
                        }
                        Button(action: {
                            self.resetTest()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 42))
                                .bold()
                                .padding()
                                .cornerRadius(40)
                                .foregroundColor(.blue)
                                .padding(5)
                        }
                        Button(action: {
                            self.resetTest()
                            self.cardsStartFlipped.toggle()
                        }) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 42))
                                .bold()
                                .padding()
                                .cornerRadius(40)
                                .foregroundColor(.blue)
                                .padding(5)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding()
        .sheet(isPresented: $showDeckEditor) {
            DeckEditorView(deck: $deck, onSave: self.resetTest)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    @State private static var deck = Deck(
        name: "tarea #1",
        cards: [
            Card(frontText: "hrana", backText: "comida"),
            Card(frontText: "jabuka", backText: "manzana"),
            Card(frontText: "zena", backText: "mujer")
        ]
    )
    
    static var previews: some View {
        TestView(deck: $deck)
    }
}
