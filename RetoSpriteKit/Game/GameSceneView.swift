//
//  GameSceneView.swift
//  RetoSpriteKit
//
//  Created by Ricardo Jorge Rodriguez Trevino on 14/08/24.
//

import SwiftUI
import SpriteKit

struct GameSceneView: View {
    @Binding var currentGameState: GameState
    
    // Crear una instancia de la escena (tipo GameScene)
    var gameScene: GameScene {
        let scene = GameScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .aspectFill
        scene.onGameOver = {
            currentGameState = .gameOver
        }
        return scene
    }
    
    // Se genera la vista
    var body: some View {
        SpriteView(scene: gameScene) // Se utilizará SpriteView debido a la naturaleza de la escena
            .ignoresSafeArea()
    }
}
