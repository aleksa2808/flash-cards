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
    Card(frontText: "slusati", backText: "escuchar"),
    Card(frontText: "pevati", backText: "cantar"),
    Card(frontText: "sto", backText: "mesa"),
    Card(frontText: "putovati", backText: "viajar"),
    Card(frontText: "zivot", backText: "vida"),
    Card(frontText: "skola", backText: "escuela"),
    Card(frontText: "rec", backText: "palabra"),
    Card(frontText: "hrana", backText: "comida"),
    Card(frontText: "slusati", backText: "escuchar"),
    Card(frontText: "pevati", backText: "cantar"),
    Card(frontText: "sto", backText: "mesa"),
    Card(frontText: "putovati", backText: "viajar"),
    Card(frontText: "zivot", backText: "vida"),
    Card(frontText: "skola", backText: "escuela"),
    Card(frontText: "rec", backText: "palabra"),
    Card(frontText: "hrana", backText: "comida"),
    Card(frontText: "slusati", backText: "escuchar"),
    Card(frontText: "pevati", backText: "cantar"),
    Card(frontText: "sto", backText: "mesa"),
    Card(frontText: "putovati", backText: "viajar"),
    Card(frontText: "zivot", backText: "vida"),
    Card(frontText: "skola", backText: "escuela"),
    Card(frontText: "rec", backText: "palabra"),
    Card(frontText: "hrana", backText: "comida"),
    Card(frontText: "slusati", backText: "escuchar"),
    Card(frontText: "pevati", backText: "cantar"),
    Card(frontText: "sto", backText: "mesa"),
    Card(frontText: "putovati", backText: "viajar"),
    Card(frontText: "zivot", backText: "vida")
]

func createCardIDSet() -> [Int] {
    var cardIDSet: [Int] = []
    for i in 0...(cards.count - 1) {
        cardIDSet.append(i)
    }
    return cardIDSet.shuffled()
}

struct ContentView: View {
    @State var cardIDSet: [Int] = createCardIDSet()
    
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
                            Text("5")
                                .font(.title)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .top)
                            Text("2")
                                .font(.title)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .top)
                            Text("24")
                                .font(.title)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .top)
                            Text("0")
                                .font(.title)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .top)
                            Text("0")
                                .font(.title)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .top)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    
                    Spacer()
                    
                    ZStack { ForEach(Array(self.cardIDSet.prefix(4).enumerated().reversed()), id: \.element) { i, cardID in
                            let card = cards[cardID]
                            Group {
                                CardView(card: card, showText: i == 0, onRemove: { _ in
                                    _ = self.cardIDSet.remove(at: 0)
                                })
                                .animation(.spring(), value: self.cardIDSet.count)
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
                            self.cardIDSet = createCardIDSet()
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
