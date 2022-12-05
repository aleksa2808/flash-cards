//
//  TestProgressView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 2.12.22..
//

import SwiftUI

struct TestProgressView: View {
    let title: String
    let testState: TestState
    private var deckCardCount: Int {
        self.testState.cardsLearned + self.testState.cardSets.reduce(0) { $0 + $1.count }
    }
    private var deckLearned: Bool {
        self.testState.cardsLearned == self.deckCardCount
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Text(self.title)
                .font(.title)
                .bold()
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            
            if self.deckCardCount > 0 {
                HStack(spacing:0) {
                    ForEach(Array(self.testState.cardSets.map{$0.count}.enumerated()), id: \.0) { stage, cardsInStage in
                        Text(String(cardsInStage))
                            .font(.title)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    Text(String(self.testState.cardsLearned))
                        .font(.title)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                .overlay(
                    alignment: .leading
                ) {
                    GeometryReader { geometry in
                        let scoreBoxWidth = geometry.size.width / CGFloat(self.testState.cardSets.count + 1)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(self.deckLearned ? Color.green : Color.yellow, lineWidth: 5)
                            .frame(maxWidth: scoreBoxWidth, alignment: .top)
                            .offset(x: CGFloat(self.testState.currentStage + (self.deckLearned ? 1 : 0)) * scoreBoxWidth)
                            .animation(.spring(), value: self.testState.cardSets)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(self.colorScheme == .light ? LightModeColors.cardFrontColor : DarkModeColors.cardFrontColor)
        .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct TestProgressView_Previews: PreviewProvider {
    static var previews: some View {
        TestProgressView(
            title: "deck name",
            testState: TestState(
                cardSets: [[Card(frontText: "front", backText: "back")], [], []],
                currentStage: 0,
                cardsLearned: 2
            )
        )
    }
}
