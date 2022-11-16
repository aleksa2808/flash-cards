//
//  CardView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

struct CardView: View {
    @State private var isShowingFront: Bool = true
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: CorrectWrong = .none
    
    private var card: Card
    private var onRemove: (_ card: Card) -> Void
    
    private var thresholdPercentage: CGFloat = 0.5 // when the card has draged 50% the width of the screen in either direction
    
    private enum CorrectWrong: Int {
        case correct, wrong, none
    }
    
    init(card: Card, onRemove: @escaping (_ card: Card) -> Void) {
        self.card = card
        self.onRemove = onRemove
    }
    
    /// What percentage of our own width have we swipped
    /// - Parameters:
    ///   - geometry: The geometry
    ///   - gesture: The current gesture translation value
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                ZStack(alignment: self.swipeStatus == .correct ? .topLeading : .topTrailing) {
                    if self.swipeStatus == .correct {
                        Text("CORRECT")
                            .font(.headline)
                            .padding()
                            .cornerRadius(10)
                            .foregroundColor(Color.green)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 3.0)
                            ).padding(24)
                            .rotationEffect(Angle.degrees(-45))
                    } else if self.swipeStatus == .wrong {
                        Text("WRONG")
                            .font(.headline)
                            .padding()
                            .cornerRadius(10)
                            .foregroundColor(Color.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 3.0)
                            ).padding(.top, 45)
                            .rotationEffect(Angle.degrees(45))
                    }
                }
                
                HStack {
                    if self.isShowingFront {
                        Text(self.card.frontText)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .bold()
                    } else {
                        Text(self.card.backText)
                            .font(.title)
                            .bold()
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .animation(.interactiveSpring(), value: self.translation)
            .offset(x: self.translation.width, y: 0)
            .rotationEffect(.degrees(Double(self.translation.width / geometry.size.width) * 25), anchor: .bottom)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        self.isShowingFront = !self.isShowingFront
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation
                        
                        if (self.getGesturePercentage(geometry, from: value)) >= self.thresholdPercentage {
                            self.swipeStatus = .correct
                        } else if self.getGesturePercentage(geometry, from: value) <= -self.thresholdPercentage {
                            self.swipeStatus = .wrong
                        } else {
                            self.swipeStatus = .none
                        }
                    }.onEnded { value in
                        // determine snap distance > 0.5 aka half the width of the screen
                        if abs(self.getGesturePercentage(geometry, from: value)) > self.thresholdPercentage {
                            self.onRemove(self.card)
                        } else {
                            self.translation = .zero
                        }
                    }
            )
        }
    }
}

// 7
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(id: 1, frontText: "hrana", backText: "comida"),
                 onRemove: { _ in
            // do nothing
        })
        .frame(height: 400)
        .padding()
    }
}
