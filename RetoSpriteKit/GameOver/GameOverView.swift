//
//  GameOverView.swift
//  RetoSpriteKit
//
//  Created by Ricardo Jorge Rodriguez Trevino on 13/08/24.
//

import SwiftUI

struct GameOverView: View {
    @Binding var currentGameState: GameState
    @State private var currentImageIndex = 0
    
    // Total number of images
    private let totalImages = 18

    var body: some View {
        ZStack {
            Image("blueBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .offset(y: -25)
            
            VStack {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .bold()
                    .padding(.top, 25)
                
                // Display the current image
                Image("teusCard\(currentImageIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width / 5,
                           maxHeight: UIScreen.main.bounds.width / 5)
                    .onAppear {
                        // Start a timer that updates the image index every 0.1 seconds
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                            currentImageIndex = (currentImageIndex + 1) % totalImages
                        }
                    }
                    .padding(.bottom)
                
                HStack {
                    
                    Spacer()
                    
                    // To restart the game
                    Button("Restart") {
                        currentGameState = .playing
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                            
                    // To return to the First Screen
                    Button("Menu") {
                        currentGameState = .mainMenu
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
            }
        }
    }
}

/*
#Preview {
    GameOverView()
}
*/
