//
//  CardView.swift
//  FlashCards
//
//  Created by Aleksa Pavlović on 16.11.22..
//

import SwiftUI

struct CardView: View {
    @State private var isShowingFront: Bool = true
    @State private var animate3d = false
    @State private var translation: CGSize = .zero
    @State private var swipePercentage: CGFloat = .zero
    
    private var card: Card
    private var showText: Bool
    private var onRemove: (_ card: Card) -> Void
    
    private var thresholdPercentage: CGFloat = 0.5
    
    init(card: Card, showText: Bool, onRemove: @escaping (_ card: Card) -> Void) {
        self.card = card
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
                    Text(self.card.frontText)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .bold()
                        .opacity(isShowingFront ? 0.0 : 1.0)
                }
                Text(self.card.backText)
                    .font(.title)
                    .bold()
                    .opacity(isShowingFront ? 1.0 : 0.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.white)
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
                        if abs(self.getSwipePercentage(geometry, from: value)) > self.thresholdPercentage {
                            self.onRemove(self.card)
                        } else {
                            self.translation = .zero
                            self.swipePercentage = .zero
                        }
                    }
            )
            .modifier(FlipEffect(flipped: $isShowingFront, angle: animate3d ? 180 : 0, axis: (x: 0, y: -1)))
            .onTapGesture {
                withAnimation(Animation.linear(duration: 0.25)) {
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
        CardView(card: Card(id: 1, frontText: "hrana", backText: "comida"),
                 showText: true,
                 onRemove: { _ in })
        .frame(height: 400)
        .padding()
    }
}
