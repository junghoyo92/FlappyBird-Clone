//
//  GameScene.swift
//  Flappy Bird (Hoy)
//
//  Created by Hoyoung Jung on 3/16/16.
//  Copyright (c) 2016 Hoyoung Jung. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    var scoreLabel = SKLabelNode()
    
    var gameoverLabel = SKLabelNode()
    var playAgainLabel = SKLabelNode()
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    
    var movingObjects = SKSpriteNode()
    var labelContainer = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver = false
    
    func makeBG() {
        /*
        This process creates the bg SKSpriteNode animation
        */
        
        // defines the animation texture/images
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        // generates the node and the position of it
        bg = SKSpriteNode(texture: bgTexture)
        bg.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bg.size.height = self.frame.height
        
        let movebg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replacebg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let movebgForever = SKAction.repeatActionForever(SKAction.sequence([movebg, replacebg]))
        
        // Creates 3 backgrounds all aligned from the left to create a infinite background loop
        for var i:CGFloat=0; i<3; i++ {
            // generates the node and the position of it
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            bg.zPosition = 1
            bg.size.height = self.frame.height
            
            bg.runAction(movebgForever)
            movingObjects.addChild(bg)
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        makeBG()
        
        // Creates the Score Label
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 80
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 170)
        scoreLabel.zPosition = 4
        self.addChild(scoreLabel)
    
/*
    This process creates the bird SKSpriteNode animation
*/
        
        // defines the animation texture/images
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        // creates points of animation
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        // generates the node and the position of it
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.zPosition = 3
        
        // defines the action process
        bird.runAction(makeBirdFlap)
        
        // Physics of play
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        // Applies Gravity
        bird.physicsBody!.dynamic = true
        // Stops Rotation
        bird.physicsBody!.allowsRotation = false
        
        // Game Control Collisions for bird
        // sets the category
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        // Can only detect collision with same types
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        // decides whether the objects can pass through each other or not
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        
        // Add bird to the scene
        self.addChild(bird)
        
       
/*
    This process creates the ground SKNode animation
*/
        // Creating a ground for correlation
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.zPosition = 2
        ground.physicsBody!.dynamic = false
        
        // Game Control Collisions for ground
        // sets the category
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        // Can only detect collision with same types
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        // decides whether the objects can pass through each other or not
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        // runes the function makePipes over time
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
        

    }
    
    func makePipes() {
        /*
        This process creates the pipes SKSpriteNode animation
        */
        // distance between pipes
        let gapHeight = bird.size.height * 3
        // random movement of pipes
        let movementAmount = arc4random() % UInt32(self.frame.size.height/2)
        // offset of pipes to maintain reasonable game play
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/4
        // pipe movement from right to left
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        
        var pipeTexture = SKTexture(imageNamed: "pipe1.png")
        var pipe1 = SKSpriteNode(texture: pipeTexture)
        
        pipe1.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.zPosition = 3
        pipe1.runAction(moveAndRemovePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe1.physicsBody!.dynamic = false
        
        // Game Control Collisions for pipe1
        // sets the category
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        // Can only detect collision with same types
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        // decides whether the objects can pass through each other or not
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(pipe1)
        
        var pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        var pipe2 = SKSpriteNode(texture: pipe2Texture)
        
        pipe2.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.zPosition = 3
        pipe2.runAction(moveAndRemovePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2Texture.size())
        pipe2.physicsBody!.dynamic = false
        
        // Game Control Collisions for pipe2
        // sets the category
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        // Can only detect collision with same types
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        // decides whether the objects can pass through each other or not
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(pipe2)
        
        // creates, moves and removes the gap for the score system
        var gap = SKNode()
        gap.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.physicsBody!.dynamic = false
        
        // Game Control Collisions for pipe2
        // sets the category
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        // Can only detect collision with same types
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        // decides whether the objects can pass through each other or not
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        movingObjects.addChild(gap)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            
            score++
            scoreLabel.text = String(score)
            
        } else {
            
            if gameOver == false {
                
                gameOver = true
                self.speed = 0
            
                gameoverLabel.fontName = "Helvetica"
                gameoverLabel.fontSize = 50
                gameoverLabel.text = "Game Over"
                gameoverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                gameoverLabel.zPosition = 4
                labelContainer.addChild(gameoverLabel)
                
                playAgainLabel.fontName = "Helvetica"
                playAgainLabel.fontSize = 30
                playAgainLabel.text = " Tap to Play Again"
                playAgainLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 60)
                playAgainLabel.zPosition = 4
                labelContainer.addChild(playAgainLabel)
                
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if gameOver == false {
        
        bird.physicsBody!.velocity = CGVectorMake(0, 0)
        bird.physicsBody!.applyImpulse(CGVectorMake(0, 50))
            
        } else {
            
            score = 0
            scoreLabel.text = "0"
            
            bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            
            
            movingObjects.removeAllChildren()
            
            makeBG()
            
            self.speed = 1
            gameOver = false
            labelContainer.removeAllChildren()
            
            
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
}