//
//  ContentView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

struct Card: Hashable, CustomStringConvertible {
    var id: Int
    
    let frontText: String
    let backText: String
    
    var description: String {
        return "pera detlic"
    }
}

struct ContentView: View {
    /// List of cards
    @State var cards: [Card] = [
        Card(id: 1, frontText: "skola", backText: "escuela"),
        Card(id: 2, frontText: "rec", backText: "palabra"),
        Card(id: 3, frontText: "hrana", backText: "comida"),
        Card(id: 4, frontText: "slusati", backText: "escuchar"),
        Card(id: 5, frontText: "pevati", backText: "cantar"),
        Card(id: 6, frontText: "sto", backText: "mesa"),
        Card(id: 6, frontText: "putovati", backText: "viajar"),
        Card(id: 6, frontText: "zivot", backText: "vida")
    ]
    
    /// Return the CardViews width for the given offset in the array
    /// - Parameters:
    ///   - geometry: The geometry proxy of the parent
    ///   - id: The ID of the current card
    private func getCardWidth(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        let offset: CGFloat = CGFloat(cards.count - 1 - id) * 10
        return geometry.size.width - offset
    }
    
    /// Return the CardViews frame offset for the given offset in the array
    /// - Parameters:
    ///   - geometry: The geometry proxy of the parent
    ///   - id: The ID of the current card
    private func getCardOffset(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        return  CGFloat(cards.count - 1 - id) * 10
    }
    
    private var maxID: Int {
        return self.cards.map { $0.id }.max() ?? 0
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                LinearGradient(gradient: Gradient(colors: [Color.init(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color.init(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))]), startPoint: .bottom, endPoint: .top)
                    .frame(width: geometry.size.width * 1.5, height: geometry.size.height)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .offset(x: -geometry.size.width / 4, y: -geometry.size.height / 2)
                
                VStack(spacing: 24) {
                    ZStack {
                        ForEach(self.cards, id: \.self) { card in
                            Group {
                                // Range Operator
                                if (self.maxID - 3)...self.maxID ~= card.id {
                                    CardView(card: card, onRemove: { removedCard in
                                        // Remove that card from our array
                                        self.cards.removeAll { $0.id == removedCard.id }
                                    })
                                    .animation(.spring(), value: self.cards.count)
                                    .frame(width: self.getCardWidth(geometry, id: card.id), height: geometry.size.height / 2)
                                    .offset(x: 0, y: geometry.size.height / 8 + self.getCardOffset(geometry, id: card.id))
                                }
                            }
                        }
                    }
                    Spacer()
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
