//
//  GameScene.swift
//  RetoSpriteKit
//
//  Created by Ricardo Jorge Rodriguez Trevino on 06/08/24.
//

import SwiftUI
import SpriteKit

// For the Physics
struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let character : UInt32 = 0b1
    static let enemy     : UInt32 = 0b10
    static let object    : UInt32 = 0b100
}

// Different Game States
enum GameState {
    case mainMenu
    case playing
    case gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Game State
    var gameState: GameState = .playing
    
    // To stop the movement
    var shouldMoveCharacter = true
    
    // Constants for the Spawn of enemies
    var timeSinceLastSpawn = 0.0 as Double
    var spawnRate = 2.0 as Double

    // Sprites
    var backgroundNodes: [SKSpriteNode] = []
    var characterNode: SKSpriteNode!
    var enemyNode: SKSpriteNode!
    var scoreManager: ScoreManager!

    weak var gameViewController: GameViewController?

    // Initialize
    override func didMove(to view: SKView) {
        setupBackground()
        setupCharacter()
        
        scoreManager = ScoreManager(scene: self)
        scoreManager.scoreLabel.zPosition = 2
        scoreManager.resetScore()

        physicsWorld.contactDelegate = self
    }
    
    // Background
    func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: "Background")
        
        for i in 0..<3 {
            let backgroundNode = SKSpriteNode(texture: backgroundTexture)
            
            backgroundNode.size = CGSize(width: size.width, height: size.height)
            backgroundNode.position = CGPoint(x: size.width / 2 + CGFloat(i) * backgroundNode.size.width, y: size.height / 2)
            
            // Set physics body to nil to avoid interaction
            backgroundNode.physicsBody = nil
            
            addChild(backgroundNode)
            backgroundNodes.append(backgroundNode)
        }
    }
    
    // Main Character
    func setupCharacter() {
        // Constants
        let scale: CGFloat = 0.5
            
        // Textures
        let characterTexture1 = SKTexture(imageNamed: "ghost1")
        let characterTexture2 = SKTexture(imageNamed: "ghost2")
        characterTexture1.filteringMode = .nearest
        characterTexture2.filteringMode = .nearest
            
        let runningAnimation = SKAction.animate(with: [characterTexture1, characterTexture2], timePerFrame: 0.10)
            
        characterNode = SKSpriteNode()
            
        characterNode.size = characterTexture1.size()
        characterNode.setScale(scale)
            
        // Position
        characterNode.position = CGPoint(x: size.width / 5,
                                         y: size.height / 4)

        // Physics
        let physicsBox = CGSize(width: characterTexture1.size().width * scale,
                                height: characterTexture1.size().height * scale)
            
        characterNode.physicsBody = SKPhysicsBody(rectangleOf: physicsBox)
            
        characterNode.physicsBody?.affectedByGravity = false
        characterNode.physicsBody?.isDynamic = true
        characterNode.physicsBody?.mass = 100.0
        
        characterNode.physicsBody?.categoryBitMask = PhysicsCategory.character
        characterNode.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.object
        characterNode.physicsBody?.collisionBitMask = PhysicsCategory.enemy | PhysicsCategory.object
            
        // Run animation
        characterNode.run(SKAction.repeatForever(runningAnimation))
        
        // Add to scene
        addChild(characterNode)
        characterNode.zPosition = 2
    }

    // Enemies
    func setupEnemy() {
        // Constants
        let scale: CGFloat = 0.5
        
        // Textures
        let enemyTexture1 = SKTexture(imageNamed: "granny1")
        let enemyTexture2 = SKTexture(imageNamed: "granny2")
        enemyTexture1.filteringMode = .nearest
        enemyTexture2.filteringMode = .nearest
        
        let enemyTexture3 = SKTexture(imageNamed: "gran1")
        let enemyTexture4 = SKTexture(imageNamed: "gran2")
        enemyTexture3.filteringMode = .nearest
        enemyTexture4.filteringMode = .nearest
 
        // Arrays of enemy textures
        let array1 = [enemyTexture1, enemyTexture2]
        let array2 = [enemyTexture3, enemyTexture4]
        
        // Randomly choose between the arrays
        let randomTexture: [SKTexture] = Bool.random() ? array1 : array2
        
        // Sprites
        let enemySprite = SKSpriteNode(texture: randomTexture[0])
        enemySprite.size = randomTexture[0].size()
        enemySprite.setScale(scale)
        
        // Animation
        let screenWidth = self.frame.size.width
        let distanceOffscreen: CGFloat = 50.0
        let distanceToMove = screenWidth + distanceOffscreen + enemyTexture1.size().width * scale
        
        let runningAnimation = SKAction.animate(with: randomTexture, timePerFrame: 0.20)
        
        let moveEnemy = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(screenWidth / 500))
        let removeEnemy = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveEnemy, removeEnemy])
        
        // Position
        enemySprite.position = CGPoint(x: size.width + distanceOffscreen, y: size.height / 4)
        
        // Physics
        let enemyContact = CGSize(width: enemyTexture1.size().width * scale,
                                  height: enemyTexture1.size().height * scale)
        enemySprite.physicsBody = SKPhysicsBody(rectangleOf: enemyContact)
        
        //enemySprite.physicsBody?.affectedByGravity = false
        enemySprite.physicsBody?.isDynamic = false
        
        enemySprite.physicsBody?.mass = 1.0
        enemySprite.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemySprite.physicsBody?.contactTestBitMask = PhysicsCategory.character
        
        // Run animation
        enemySprite.run(SKAction.group([moveAndRemove, SKAction.repeatForever(runningAnimation)]))
        
        enemySprite.isPaused = isPaused
        
        enemySprite.name = "enemigo"
        
        // Add to scene
        addChild(enemySprite)
        enemySprite.zPosition = 2
    }
    
    // Collectable Objects (Flowers)
    func setupCollectable() {
        // Constants
        let scale: CGFloat = 0.5
        
        let objectTexture = SKTexture(imageNamed: "flower")
        objectTexture.filteringMode = .nearest
        
        let objectNode = SKSpriteNode(texture: objectTexture)
        objectNode.setScale(0.5)
        
        // Animation
        let screenWidth = self.frame.size.width
        let distanceOffscreen: CGFloat = 50.0
        let distanceToMove = screenWidth + distanceOffscreen + objectTexture.size().width * scale
        
        let moveObject = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(screenWidth / 500))
        let removeObject = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([moveObject, removeObject])
        
        // Position
        objectNode.position = CGPoint(x: size.width + distanceOffscreen, y: size.height / 4)
        objectNode.zPosition = 2
        
        // Physics
        let objectContact = CGSize(width: objectTexture.size().width * scale,
                                   height: objectTexture.size().height * scale)
        objectNode.physicsBody = SKPhysicsBody(rectangleOf: objectContact)
        objectNode.physicsBody?.isDynamic = false
        objectNode.physicsBody?.mass = 1.0
        objectNode.physicsBody?.categoryBitMask = PhysicsCategory.object
        objectNode.physicsBody?.contactTestBitMask = PhysicsCategory.character
        
        // Run movement
        objectNode.run(moveAndRemove)
        
        objectNode.isPaused = isPaused
        
        // Add to scene
        addChild(objectNode)
    }
    
    // Fading Out Function
    var isClickable = true
    var lastFadeOutTime: TimeInterval = 0.0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isClickable else {
            return
        }
                
        switch gameState {
        case .mainMenu:
            print("mainMenu")
        case .playing:
            handlePlayingTouches(touches)
        case .gameOver:
            //handleGameOverTouches(touches)
            print("gameOver")
        }
    }
    
    func handlePlayingTouches(_ touches: Set<UITouch>) {
        // Disable physics interactions during the fade-out animation
        characterNode.physicsBody?.categoryBitMask = PhysicsCategory.none
        characterNode.physicsBody?.contactTestBitMask = PhysicsCategory.none
        characterNode.physicsBody?.collisionBitMask = PhysicsCategory.none

        let fadeOutAction = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 1.0)

        let sequenceAction = SKAction.sequence([fadeOutAction, fadeInAction])

        characterNode.run(sequenceAction) {
            self.isClickable = true

            // Restore physics interactions after the fade-out animation
            self.characterNode.physicsBody?.categoryBitMask = PhysicsCategory.character
            self.characterNode.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
            self.characterNode.physicsBody?.collisionBitMask = PhysicsCategory.enemy
        }
        
        isClickable = false
                   
        /*
        for touch in touches {
            let location = touch.location(in: self)
            
        }
         */
    }

    /*
    func handleGameOverTouches(_ touches: Set<UITouch>) {
        // Handle touches for the Game Over state
        for touch in touches {
            let location = touch.location(in: self)

        }
    }
     */

    
    // Add the enemies and move the background
    override func update(_ currentTime: TimeInterval) {
        guard shouldMoveCharacter else {
            return
        }

        if !isPaused {
            moveBackground()
            scoreManager.updateScore()

            if currentTime - timeSinceLastSpawn > spawnRate {
                timeSinceLastSpawn = currentTime
                spawnRate = Double.random(in: 1.0 ..< 3.5)

                if Int.random(in: 0...10) < 9 {
                    setupEnemy()
                } else {
                    setupCollectable()
                }
            }
        }
    }
    
    // Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.character && contact.bodyB.categoryBitMask == PhysicsCategory.enemy) ||
           (contact.bodyA.categoryBitMask == PhysicsCategory.enemy && contact.bodyB.categoryBitMask == PhysicsCategory.character) {
            
            // Show Game Over
            gameState = .gameOver
                                    
            // Textures
            let characterTexture1 = SKTexture(imageNamed: "ghostScared1")
            let characterTexture2 = SKTexture(imageNamed: "ghostScared2")
            characterTexture1.filteringMode = .nearest
            characterTexture2.filteringMode = .nearest
                
            let scaredAnimation = SKAction.animate(with: [characterTexture1, characterTexture2], timePerFrame: 0.10)
            
            // Scared animation
            characterNode.run(SKAction.repeatForever(scaredAnimation))
            
            // If they collide, the ghost stays in the same position
            shouldMoveCharacter = false
            characterNode.position = CGPoint(x: size.width / 5, y: size.height / 4)
            
            characterNode.physicsBody?.isDynamic = false
            characterNode.physicsBody?.affectedByGravity = false
            characterNode.physicsBody?.velocity = CGVector.zero
        }
        else if (contact.bodyA.categoryBitMask == PhysicsCategory.character && contact.bodyB.categoryBitMask == PhysicsCategory.object) ||
                (contact.bodyA.categoryBitMask == PhysicsCategory.object && contact.bodyB.categoryBitMask == PhysicsCategory.character) {
            
            // Flower and character collided
            if let flowerNode = (contact.bodyA.categoryBitMask == PhysicsCategory.object) ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                
                // Remove the flower from the scene
                flowerNode.removeFromParent()
                
                // Add 10 points to the score
                scoreManager.addScore(points: 10)
            }
        }
    }
    
    // To move the Background
    func moveBackground() {
        let backgroundMoveSpeed: CGFloat = 10.0

        for backgroundNode in backgroundNodes {
            backgroundNode.position.x -= backgroundMoveSpeed

            // Check if background is completely offscreen, then move it to the right
            if backgroundNode.position.x < -backgroundNode.size.width / 2 {
                backgroundNode.position.x += backgroundNode.size.width * CGFloat(backgroundNodes.count)
            }
        }
    }
}

struct GameSceneView: View {
    var gameScene: GameScene {
        let scene = GameScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: gameScene)
            .ignoresSafeArea()
    }
}
