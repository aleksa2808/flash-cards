//
//  CardView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

struct CardView: View {
    @State private var flipped = false
    @State private var animate3d = false
    @State private var translation: CGSize = .zero
    @State private var swipePercentage: CGFloat = .zero
    
    private let card: Card
    private let startFlipped: Bool
    private let showText: Bool
    private let onRemove: (_ correct: Bool) -> Void
    
    private let thresholdPercentage: CGFloat = 0.3
    
    @Environment(\.colorScheme) private var colorScheme
    private var cardFrontColor: Color {
        self.colorScheme == .light ? LightModeColors.cardFrontColor : DarkModeColors.cardFrontColor
    }
    private var cardBackColor: Color {
        self.colorScheme == .light ? LightModeColors.cardBackColor : DarkModeColors.cardBackColor
    }
    
    init(card: Card, startFlipped: Bool, showText: Bool, onRemove: @escaping (_ correct: Bool) -> Void) {
        self.card = card
        self.startFlipped = startFlipped
        self.showText = showText
        self.onRemove = onRemove
    }
    
    private func getSwipePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                    .opacity(max(0, self.swipePercentage / self.thresholdPercentage))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                Text("WRONG")
                    .font(.headline)
                    .padding()
                    .cornerRadius(10)
                    .foregroundColor(Color.red)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 3.0)
                    ).padding(24)
                    .rotationEffect(Angle.degrees(45))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .opacity(abs(min(0, self.swipePercentage / self.thresholdPercentage)))
                
                if self.showText {
                    VStack {
                        if self.startFlipped == self.flipped {
                            Text(self.card.frontText)
                                .font(.title)
                                .bold()
                        } else {
                            Text(self.card.backText)
                                .font(.title)
                                .bold()
                        }
                    }
                    .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(self.startFlipped == self.flipped ? self.cardFrontColor : self.cardBackColor)
            .cornerRadius(10)
            .shadow(radius: 5)
            .animation(.interactiveSpring(), value: self.translation)
            .offset(x: self.translation.width, y: 0)
            .rotationEffect(.degrees(Double(self.translation.width / geometry.size.width) * 25), anchor: .bottom)
            .allowsHitTesting(self.showText)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation
                        self.swipePercentage = self.getSwipePercentage(geometry, from: value)
                    }.onEnded { value in
                        self.translation = .zero
                        self.swipePercentage = .zero
                        
                        let swipePercentage = self.getSwipePercentage(geometry, from: value)
                        if abs(swipePercentage) > self.thresholdPercentage {
                            if self.flipped {
                                self.flipped = false
                                self.animate3d.toggle()
                            }
                            self.onRemove(swipePercentage > 0)
                        }
                    }
            )
            .modifier(FlipEffect(flipped: $flipped, angle: animate3d ? 180 : 0, axis: (x: 0, y: -1)))
            .onTapGesture {
                withAnimation(Animation.spring()) {
                    self.animate3d.toggle()
                }
            }
        }
    }
}

struct FlipEffect: GeometryEffect {
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    @Binding var flipped: Bool
    var angle: Double
    let axis: (x: CGFloat, y: CGFloat)
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        
        DispatchQueue.main.async {
            self.flipped = self.angle >= 90 && self.angle < 270
        }
        
        let tweakedAngle = flipped ? -180 + angle : angle
        let a = CGFloat(Angle(degrees: tweakedAngle).radians)
        
        var transform3d = CATransform3DIdentity;
        transform3d.m34 = -1/max(size.width, size.height)
        
        transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
        
        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
        
        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(frontText: "hrana", backText: "comida"),
                 startFlipped: false,
                 showText: true,
                 onRemove: { _ in })
        .frame(height: 400)
        .padding()
    }
}
