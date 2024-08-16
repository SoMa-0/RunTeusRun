//
//  ContentView.swift
//  RetoSpriteKit
//
//  Created by Ricardo Jorge Rodriguez Trevino on 06/08/24.
//

import SwiftUI

enum GameState {
    case mainMenu
    case playing
    case gameOver
}

struct ContentView: View {
    
    // The navigation of the app is based on the state of the game.
    // Each state presents a different view on the SwiftUI app structure
    @State var currentGameState: GameState = .mainMenu
    
    var body: some View {
        
        switch currentGameState {
        case .mainMenu:
            StartingView(currentGameState: $currentGameState)
        case .playing:
            GameSceneView(currentGameState: $currentGameState)
        case .gameOver:
            GameOverView(currentGameState: $currentGameState)
        }
    }
}

#Preview {
    ContentView()
}
