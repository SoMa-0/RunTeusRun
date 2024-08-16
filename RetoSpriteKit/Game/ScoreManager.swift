//
//  ScoreManager.swift
//  RetoSpriteKit
//
//  Created by Ricardo Jorge Rodriguez Trevino on 09/08/24.
//

import SpriteKit

// Helper for the Score
class ScoreManager {

    var scoreLabel: SKLabelNode!
    var distanceTraveled: CGFloat = 0.0
    var score: Int = 0
    var flowerCount: Int = 0
    
    weak var scene: SKScene?

    // Initializes the place where you will put the objects, as well as the objects that will represent the score
    init(scene: SKScene) {
        self.scene = scene

        setupScoreLabel(in: scene)
        loadHighScore()
    }

    // Score Label
    func setupScoreLabel(in scene: SKScene) {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Arial"
        scoreLabel.fontSize = 30
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: scene.size.height - 55)
                
        scene.addChild(scoreLabel)
    }

    // Update the score based on the distance
    func updateScore() {

        score += 1
        
        // Update the score label text
        scoreLabel.text = "Score: \(score + flowerCount)"
        
        // Check for new high score
        checkAndUpdateHighScore()
    }
    
    // Extra points (obtained by collecting objects) are added.
    func addScore(points: Int) {
        // Add points to the score
        flowerCount += points * 100 // Add 100 points for each object collected

        // Update the score label
        scoreLabel.text = "Score: \(score + flowerCount)"
        
        // Check for new high score
        checkAndUpdateHighScore()
    }
    
    // The score is restarted each time a new game is started
    func resetScore() {
        score = 0
        flowerCount = 0
        updateScoreLabel()
    }
    
    // The score label is updated
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score + flowerCount)"
    }
    
    // UserDefaults: "An interface to the user’s defaults database, where you store key-value pairs persistently across launches of your app"
    // Basically you are building a key to save a single data across the whole app
    private let highScoreKey = "HighScore"

    // Load high score from UserDefaults to display it in the Starting View
    private func loadHighScore() {
        if let savedHighScore = UserDefaults.standard.value(forKey: highScoreKey) as? Int {
            score = savedHighScore
        }
    }

    // Check and update high score if needed
    private func checkAndUpdateHighScore() {
        let currentTotalScore = score + flowerCount

        if currentTotalScore > UserDefaults.standard.integer(forKey: highScoreKey) {
            // Update high score in UserDefaults
            UserDefaults.standard.set(currentTotalScore, forKey: highScoreKey)
            UserDefaults.standard.synchronize()
        }
    }
}
