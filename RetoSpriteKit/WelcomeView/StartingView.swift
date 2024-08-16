//
//  StartingView.swift
//  RetoSpriteKit
//
//  Created by Ricardo Jorge Rodriguez Trevino on 08/08/24.
//

import Foundation
import SwiftUI

struct StartingView: View {
    @Binding var currentGameState: GameState
    
    @State private var currentImageIndex = 0
    @State private var scale: CGFloat = 1.0
    let images = ["teusEnojado", "teusFeliz", "teusPreocupado"]
    
    // Get the best score from UserDefaults
    let bestScore = UserDefaults.standard.integer(forKey: "HighScore")

    var body: some View {
        
        ZStack {
            Image("blueBackground")
                .resizable() // makes the image view resizable
                .scaledToFill() // scales the image to fill its container while preserving its aspect ratio
                .ignoresSafeArea() // makes the image extend to the edges of the screen
                .offset(y: -25) // adjusts the position of the image by applying a vertical offset
            
            Image(images[currentImageIndex])
                .resizable()
                .scaledToFit() // scales the image to fit within its container while preserving its aspect ratio
                // size of the image
                .frame(maxWidth: UIScreen.main.bounds.width / 5,
                       maxHeight: UIScreen.main.bounds.width / 5)
                .scaleEffect(scale)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            scale = 1.2
                        }
                        withAnimation(.easeInOut(duration: 0.3).delay(0.3)) {
                            scale = 1.0
                        }
                        currentImageIndex = (currentImageIndex + 1) % images.count
                    }
                }
            
            // Give a different shape to the text
            CircleText(radius: 110, text: "Run, Teus, Run!")
                .font(.custom("PixelifySans-VariableFont_wght", size: 24))
                .foregroundStyle(.white)
            
            // Best score display
            VStack {
                HStack {
                    Text("Best: \(bestScore)")
                        .font(.custom("PixelifySans-VariableFont_wght", size: 24))
                        .foregroundColor(.white)
                        .padding([.top, .leading], 20)
                    Spacer()
                }
                Spacer()
            }
            .padding([.top], 25)
            
            // Button on the bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // Change the game state to start playing
                    Button(action: {
                        currentGameState = .playing
                    }) {
                        Text("Start")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding([.bottom, .trailing], 20)
                }
            }
        }
    }
}

// For the rounded text
struct CircleText: View {
    var radius: Double
    var text: String
    var kerning: CGFloat = 5.0
    
    private var texts: [(offset: Int, element: Character)] {
        return Array(text.enumerated())
    }
    
    @State var textSizes: [Int:Double] = [:]
        
    var body: some View {
        ZStack {
            ForEach(self.texts, id: \.self.offset) { (offset, element) in
                VStack {
                    Text(String(element))
                        .kerning(self.kerning)
                        .background(Sizeable())
                        .onPreferenceChange(WidthPreferenceKey.self,
                                            perform: { size in
                            self.textSizes[offset] = Double(size)
                        })
                    Spacer()
                }
                .rotationEffect(self.angle(at: offset))
            }
        }
        .frame(width: 300, height: 300, alignment: .center)
    }
    
    private func angle(at index: Int) -> Angle {
        guard let labelSize = textSizes[index] else {return .radians(0)}
        let percentOfLabelInCircle = labelSize / radius.perimeter
        let labelAngle = 2 * Double.pi * percentOfLabelInCircle
        let totalSizeOfPreChars = textSizes.filter{$0.key < index}.map{$0.value}.reduce (0,+)
        let percenOfPreCharInCircle = totalSizeOfPreChars / radius.perimeter
        let angleForPreChars = 2 * Double.pi * percenOfPreCharInCircle
        return .radians(angleForPreChars + labelAngle)
    }

}

struct WidthPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat (0)
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue ()
    }
}

struct Sizeable: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference (key: WidthPreferenceKey.self, value: geometry.size.width)
        }
    }
}

extension Double {
    var perimeter: Double {
        return self * 2 * .pi
    }
}

