//
//  ContentView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

struct Card: Hashable {
    let frontText: String
    let backText: String
}

let cards: [Card] = [
    Card(frontText: "skola", backText: "escuela"),
    Card(frontText: "rec", backText: "palabra"),
    Card(frontText: "hrana", backText: "comida"),
    //    Card(frontText: "slusati", backText: "escuchar"),
    //    Card(frontText: "pevati", backText: "cantar"),
    //    Card(frontText: "sto", backText: "mesa"),
    //    Card(frontText: "putovati", backText: "viajar"),
    //    Card(frontText: "zivot", backText: "vida"),
    //    Card(frontText: "skola", backText: "escuela"),
    //    Card(frontText: "rec", backText: "palabra"),
    //    Card(frontText: "hrana", backText: "comida"),
    //    Card(frontText: "slusati", backText: "escuchar"),
    //    Card(frontText: "pevati", backText: "cantar"),
    //    Card(frontText: "sto", backText: "mesa"),
    //    Card(frontText: "putovati", backText: "viajar"),
    //    Card(frontText: "zivot", backText: "vida"),
    //    Card(frontText: "skola", backText: "escuela"),
    //    Card(frontText: "rec", backText: "palabra"),
    //    Card(frontText: "hrana", backText: "comida"),
    //    Card(frontText: "slusati", backText: "escuchar"),
    //    Card(frontText: "pevati", backText: "cantar"),
    //    Card(frontText: "sto", backText: "mesa"),
    //    Card(frontText: "putovati", backText: "viajar"),
    //    Card(frontText: "zivot", backText: "vida"),
    //    Card(frontText: "skola", backText: "escuela"),
    //    Card(frontText: "rec", backText: "palabra"),
    //    Card(frontText: "hrana", backText: "comida"),
    //    Card(frontText: "slusati", backText: "escuchar"),
    //    Card(frontText: "pevati", backText: "cantar"),
    //    Card(frontText: "sto", backText: "mesa"),
    //    Card(frontText: "putovati", backText: "viajar"),
    //    Card(frontText: "zivot", backText: "vida")
]

let numOfStages = 4
func createCardIDSets() -> [[Int]] {
    var cardIDSets: [[Int]] = []
    
    var cardIDSet: [Int] = []
    for i in 0 ..< cards.count {
        cardIDSet.append(i)
    }
    cardIDSets.append(cardIDSet.shuffled())
    
    for _ in 1 ..< numOfStages{
        cardIDSets.append([])
    }
    
    return cardIDSets
}

struct ContentView: View {
    @State var cardIDSets: [[Int]] = createCardIDSets()
    @State var currentStage: Int = 0
    @State var cardsLearned: Int = 0
    @State var swipeCount: Int = 0
    
    private func getCardOffset(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return CGFloat(position) * -10
    }
    
    private func getCardWidth(_ geometry: GeometryProxy, position: Int) -> CGFloat {
        return geometry.size.width + getCardOffset(geometry, position: position)
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
                            ForEach(Array(self.cardIDSets.map{$0.count}.enumerated()), id: \.0) { stage, cardsInStage in
                                if self.cardsLearned != cards.count && stage == self.currentStage {
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
                            if self.cardsLearned == cards.count {
                                Text(String(self.cardsLearned))
                                    .font(.title)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .top)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.green, lineWidth: 5)
                                    )
                            } else {
                                Text(String(self.cardsLearned))
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
                    
                    if self.cardsLearned == cards.count {
                        Text("Deck learned!")
                            .font(.title)
                            .bold()
                            .foregroundColor(.green)
                    } else {
                        ZStack {
                            ForEach(Array(self.cardIDSets[self.currentStage].prefix(4).enumerated().reversed()), id: \.element) { i, cardID in
                                let card = cards[cardID]
                                CardView(card: card, showText: i == 0, onRemove: { correct in
                                    // only purpose is to update animations. is there a better way?
                                    self.swipeCount += 1
                                    
                                    let removedCardID = self.cardIDSets[self.currentStage].remove(at: 0)
                                    if correct {
                                        if self.currentStage == numOfStages - 1 {
                                            self.cardsLearned += 1
                                        } else {
                                            self.cardIDSets[self.currentStage + 1].append(removedCardID)
                                        }
                                    } else if self.currentStage > 0 {
                                        self.cardIDSets[self.currentStage - 1].append(removedCardID)
                                    } else {
                                        self.cardIDSets[self.currentStage].append(removedCardID)
                                    }
                                    
                                    if self.cardIDSets[self.currentStage].isEmpty {
                                        if self.currentStage > 0 && !self.cardIDSets[self.currentStage - 1].isEmpty {
                                            self.currentStage -= 1
                                            self.cardIDSets[self.currentStage] = self.cardIDSets[self.currentStage].shuffled()
                                        } else if self.currentStage < numOfStages - 1 {
                                            self.currentStage += 1
                                            self.cardIDSets[self.currentStage] = self.cardIDSets[self.currentStage].shuffled()
                                        } else {
                                            
                                        }
                                    }
                                })
                                .animation(.spring(), value: self.swipeCount)
                                .frame(width: self.getCardWidth(geometry, position: i), height: geometry.size.height / 2)
                                .offset(x: 0, y: self.getCardOffset(geometry, position: i))
                                
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {}) {
                            Text("Edit stack")
                                .font(.title)
                                .bold()
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(40)
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        Button(action: {
                            self.cardIDSets = createCardIDSets()
                            self.currentStage = 0
                            self.cardsLearned = 0
                        }) {
                            Text("Start over")
                                .font(.title)
                                .bold()
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(40)
                                .foregroundColor(.white)
                                .padding(10)
                        }
                    }
                }
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
