//
//  GameScene.swift
//  Deadline
//
//  Created by six on 11/2/16.
//  Copyright © 2016 six. All rights reserved.
//

import SpriteKit
import GameplayKit

let playfieldCategory = UInt32(0x01 << 0)
let ballCategory      = UInt32(0x01 << 1)
let playerCategory    = UInt32(0x01 << 2)
let brickCategory     = UInt32(0x01 << 3)
let deadlineCategory  = UInt32(0x01 << 4)

let scaleToNormal   = SKAction.scale(to: 0.5,   duration: 0.5)
let scaleToNothing  = SKAction.scale(to: 0.001, duration: 0.2)
let scaleToInfinity = SKAction.scale(to: 5,     duration: 1.0)

let sound = Sound()

public class GameScene: SKScene, SKPhysicsContactDelegate {
    lazy var ballHitPlayfield : UInt32 = playfieldCategory | ballCategory
    lazy var ballHitBrick     : UInt32 = ballCategory      | brickCategory
    lazy var ballHitDeadline  : UInt32 = deadlineCategory  | ballCategory
    lazy var brickHitDeadline : UInt32 = deadlineCategory  | brickCategory
    lazy var ballHitPaddle    : UInt32 = ballCategory      | playerCategory
    lazy var brickHitPaddle   : UInt32 = brickCategory     | playerCategory
    
    var initialized = false // deal with sceneDidLoad is called twice due to scene editor bug :(
    
    let message    = SKLabelNode(fontNamed:"Chalkduster")
    let scoreBoard = SKLabelNode(fontNamed:"Chalkduster")
    let wallLeft   = SKLabelNode(fontNamed:"Chalkduster")

    var deadline: DeadLine?
    var contactLine: DeathContactLine?
    
    var score      = 0
    var balls      = 3
    var wall       = [Brick: Bool]()
    var inPlay     = false
    
    let player     = Player()
    var ball : Ball?
    
    private var lastUpdateTime : TimeInterval = 0

    override public func sceneDidLoad() {
        // deal with sceneDidLoad is called twice due to scene editor bug :(
        guard initialized == false else {return}
        initialized = true

        // sound
        Sound.scene = self
        
        // message
        message.text      = "Ready Player One"
        message.fontSize  = 65
        message.position  = CGPoint(x:(scene?.frame.midX)!, y:(scene?.frame.midY)!)
        message.zPosition = 2.0
        addChild(message)
        
        // scoreboard
        scoreBoard.text     = ""
        scoreBoard.fontSize = 30
        scoreBoard.position = CGPoint(x: (scene?.frame.minX)! + 15, y: (scene?.frame.maxY)! - 30)
        scoreBoard.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(scoreBoard)
        
        // wallLeft
        wallLeft.text = ""
        wallLeft.fontSize = 30
        wallLeft.position = CGPoint(x:(scene?.frame.maxX)! - 45, y: (scene?.frame.maxY)! - 30)
        addChild(wallLeft)
        
        // deadline
        deadline = DeadLine(scene: self)       // the for show special effect
        contactLine = DeathContactLine(scene: self) // the actual line used to determine contact
        
        // player
        player.position = CGPoint(x: 150 ,y: (scene?.frame.minY)! + 45)
        addChild(player)
    }
    
    func startGame() {
        // playfield
        physicsWorld.contactDelegate = self
        
        physicsBody                  = SKPhysicsBody(edgeLoopFrom: (scene?.frame)!)
        physicsBody!.friction        = 0.0
        physicsBody!.categoryBitMask = playfieldCategory
        scene?.physicsBody           = physicsBody
        
        // player
        player.physicsBody!.categoryBitMask = playerCategory
        player.physicsBody!.contactTestBitMask = brickCategory
        
        // deadline
        contactLine?.physicsBody?.categoryBitMask = deadlineCategory

        newGame()
    }
    
    // new game
    func newGame() {
        for (brick, _) in wall {brickDie(brick)}
        
        if wall.count == 0 {wallUp()}
        
        score  = 0
        balls  = 3
        inPlay = false
        
        if ball != nil {
            ball!.removeFromParent()
            ball = nil
        }
        
        scoreBoard.text  = "0"
        message.text     = "Ready Player One"
        message.isHidden = false
    }
    
    // new wall
    func wallUp() {
        let leftX = Int(scene!.frame.minX)
        let topY = Int(scene!.frame.maxY)
        
        for y in stride(from: topY - 50, to: topY - 170, by: -30) {
            for x in stride(from: leftX + 90, to: leftX + 950, by: 70) {
                let brick = Brick(x: x, y: y)
                wall[brick] = true
                
                brick.physicsBody!.categoryBitMask    = brickCategory
                brick.physicsBody!.contactTestBitMask = deadlineCategory
                
                addChild(brick)
            }
        }
        
        wallLeft.text = "\(wall.count)"
    }
    
    // collision resolution
    public func didBegin(_ contact: SKPhysicsContact) {
        let all = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch all {
        case ballHitPlayfield:
            sound.ballHitWall()
            ball?.kick()
            
        case ballHitDeadline:
            sound.ballDeathknell()
            ball?.run(scaleToNothing, completion: {self.die()})
            
        case ballHitBrick:
            let brick = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            (brick.node as! Brick).removeAG()
            ball?.kick()
            
        case brickHitDeadline:
            let pBody = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            scoreAndRemoveBrick(pBody.node! as! Brick, multiplier: 1)
            
        case ballHitPaddle:
            sound.ballHitPaddle()
            ball?.kick()
            
        case brickHitPaddle:
            let pBody = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            scoreAndRemoveBrick(pBody.node! as! Brick, multiplier: 2)
            
        default:
            print("default collision")
            ball?.kick()
        }
    }
    
    // death of a player
    func die() {
        ball?.removeFromParent()
        ball = nil
        if balls == 0 {message.text = "Game Over"}
        message.isHidden = false
    }
    
    func brickDie(_ brick: Brick) {
        brick.removeFromParent()
        
        wall.removeValue(forKey: brick)
        if wall.count == 0 {wallUp()}
        
        wallLeft.text   = "\(wall.count)"
    }
    
    // death of a brick
    func scoreAndRemoveBrick(_ brick: Brick, multiplier: Int) {
        guard (brick.userData?["dying"]) as? Bool == false else {return} // dying bricks shouldn't die again
        brick.userData?["dying"] = true

        let brickValue = brick.score() * multiplier
        score += brickValue
        scoreBoard.text = "\(score)"
        let prize = SKLabelNode(fontNamed:"Chalkduster")
        prize.text = String(brickValue)
        prize.position = brick.position
        prize.fontSize = 10
        prize.zPosition = -1.0
        
        addChild(prize)
        prize.run(scaleToInfinity, completion: {prize.removeFromParent()})
        
        brick.physicsBody?.isDynamic = false // dead bricks can't collide again
        
        //sound.run(brickDeathknell)
        sound.brickDeathknell()
        brick.run(scaleToNothing, completion: {self.brickDie(brick)})
    }
    
    func newBall() {
        if (balls > 0) { // if no ball in play AND there are any left, launch one
            message.isHidden = true
            balls -= 1
            ball = Ball(scene: self)

            ball?.physicsBody!.categoryBitMask    = ballCategory
            ball?.physicsBody!.contactTestBitMask = playfieldCategory | deadlineCategory | playerCategory | brickCategory
            ball?.run(scaleToNormal)
        }
        else {
            newGame()
        }
    }
    
    override public func update(_ currentTime: TimeInterval) { // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {self.lastUpdateTime = currentTime}
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        if dt > 0.1 {
//            deadline?.randomizeColor()
            self.lastUpdateTime = currentTime
        }
    }
}
