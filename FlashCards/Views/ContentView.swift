//
//  ContentView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

func createCardIDSets(deck: [Card]) -> [[Int]] {
    let numOfStages = 4
    
    var cardIDSets: [[Int]] = []
    
    var cardIDSet: [Int] = []
    for i in 0 ..< deck.count {
        cardIDSet.append(i)
    }
    cardIDSets.append(cardIDSet.shuffled())
    
    for _ in 1 ..< numOfStages {
        cardIDSets.append([])
    }
    
    return cardIDSets
}

struct TestState {
    var cardIDSets: [[Int]]
    var currentStage: Int
    var cardsLearned: Int
    
    mutating func reset(deck: [Card]) {
        self.cardIDSets = createCardIDSets(deck: deck)
        self.currentStage = 0
        self.cardsLearned = 0
    }
}

struct ContentView: View {
    @Binding var deck: [Card]
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: ()->Void

    @State private var testState: TestState
    @State private var testIteration = 0
    @State private var deckFlipped = false
    @State private var swipeCount: Int = 0
    @State private var showDeckEditor = false
    
    // TODO: need @escaping ?
    init(deck: Binding<[Card]>, saveAction: @escaping ()->Void) {
        self._deck = deck
        self._testState = State(initialValue: TestState(
            cardIDSets: createCardIDSets(deck: deck.wrappedValue),
            currentStage: 0,
            cardsLearned: 0
        ))
        self.saveAction = saveAction
    }
    
    private func getCardOffset(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return CGFloat(position) * -10
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return geometry.size.width + getCardOffset(geometry, position: position)
    }
    
    private func resetTest() {
        self.testState.reset(deck: self.deck)
        self.testIteration += 1
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
                            ForEach(Array(self.testState.cardIDSets.map{$0.count}.enumerated()), id: \.0) { stage, cardsInStage in
                                if self.testState.cardsLearned != self.deck.count && stage == self.testState.currentStage {
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
                            if self.testState.cardsLearned == self.deck.count && !self.deck.isEmpty {
                                Text(String(self.testState.cardsLearned))
                                    .font(.title)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .top)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.green, lineWidth: 5)
                                    )
                            } else {
                                Text(String(self.testState.cardsLearned))
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
                    
                    if self.testState.cardsLearned == self.deck.count {
                        if !self.deck.isEmpty {
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
                            ForEach(Array(self.testState.cardIDSets[self.testState.currentStage].prefix(4).enumerated().reversed()), id: \.element) { i, cardID in
                                let card = self.deck[cardID]
                                CardView(card: card, frontFacing: !self.deckFlipped, showText: i == 0, onRemove: { correct in
                                    // TODO: simplify
                                    
                                    // TODO: only purpose is to update animations. is there a better way?
                                    self.swipeCount += 1
                                    
                                    let removedCardID = self.testState.cardIDSets[self.testState.currentStage].remove(at: 0)
                                    if correct {
                                        if self.testState.currentStage == self.testState.cardIDSets.count - 1 {
                                            self.testState.cardsLearned += 1
                                        } else {
                                            self.testState.cardIDSets[self.testState.currentStage + 1].append(removedCardID)
                                        }
                                    } else if self.testState.currentStage > 0 {
                                        self.testState.cardIDSets[self.testState.currentStage - 1].append(removedCardID)
                                    } else {
                                        self.testState.cardIDSets[self.testState.currentStage].append(removedCardID)
                                    }
                                    
                                    if self.testState.cardIDSets[self.testState.currentStage].isEmpty {
                                        if self.testState.currentStage > 0 && !self.testState.cardIDSets[self.testState.currentStage - 1].isEmpty {
                                            self.testState.currentStage -= 1
                                            self.testState.cardIDSets[self.testState.currentStage] = self.testState.cardIDSets[self.testState.currentStage].shuffled()
                                        } else if self.testState.currentStage < self.testState.cardIDSets.count - 1 {
                                            self.testState.currentStage += 1
                                            self.testState.cardIDSets[self.testState.currentStage] = self.testState.cardIDSets[self.testState.currentStage].shuffled()
                                        }
                                    }
                                })
                                .animation(.spring(), value: self.swipeCount)
                                .frame(width: self.getCardWidth(geometry, position: i), height: geometry.size.height / 2)
                                .offset(x: 0, y: self.getCardOffset(geometry, position: i))
                            }
                        }
                        .id(self.testIteration)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            self.showDeckEditor.toggle()
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
                            self.resetTest()
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
                            self.resetTest()
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
        .sheet(isPresented: $showDeckEditor) {
            DeckEditorView(deck: $deck, onSave: self.resetTest)
        }
        .onChange(of: self.scenePhase) { phase in
            if phase == .inactive {
                self.saveAction()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @State private static var deck = [
        Card(frontText: "hrana", backText: "comida"),
        Card(frontText: "jabuka", backText: "manzana"),
        Card(frontText: "zena", backText: "mujer")
    ]
    
    static var previews: some View {
        ContentView(deck: $deck, saveAction: {})
    }
}
