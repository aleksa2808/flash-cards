//
//  StackEditorView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 24.11.22..
//

import SwiftUI

struct StackEditorView: View {
    @Binding var cards: [Card]
    
    var body: some View {
        List {
            ForEach($cards) { $card in
                HStack {
                    TextField("Front text", text: $card.frontText)
                    TextField("Back text", text: $card.backText)
                }.textFieldStyle(RoundedBorderTextFieldStyle())
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
