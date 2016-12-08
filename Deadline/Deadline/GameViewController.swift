//
//  GameViewController.swift
//  Deadline
//
//  Created by six on 11/2/16.
//  Copyright © 2016 six. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameController

class GameViewController: UIViewController, SKPhysicsContactDelegate {
    let brickHitPaddleSound = SKAction.playSoundFileNamed("brick_hit_paddle.mp3",     waitForCompletion: false)
    let ballHitPaddleSound  = SKAction.playSoundFileNamed("ball_hits_paddle.mp3",     waitForCompletion: false)
    let ballHitWallSound    = SKAction.playSoundFileNamed("ball_hit_wall.mp3",        waitForCompletion: false)
    let ballDeathknell      = SKAction.playSoundFileNamed("ball_hits_deadline.mp3",   waitForCompletion: false)
    let brickDeathknell     = SKAction.playSoundFileNamed("brick_hits_deadline2.mp3", waitForCompletion: false)

    var score      = 0
    var balls      = 3
    var wall       = [Brick: Bool]()
    var inPlay     = false
    
    let message    = SKLabelNode(fontNamed:"Chalkduster")
    let scoreBoard = SKLabelNode(fontNamed:"Chalkduster")
    let wallLeft   = SKLabelNode(fontNamed:"Chalkduster")
    let player     = Player()
    var ball : Ball?
    
    let playfieldCategory = UInt32(0x01 << 0)
    let ballCategory      = UInt32(0x01 << 1)
    let playerCategory    = UInt32(0x01 << 2)
    let brickCategory     = UInt32(0x01 << 3)
    let deadlineCategory  = UInt32(0x01 << 4)
    
    lazy var ballHitPlayfield : UInt32 = self.playfieldCategory | self.ballCategory
    lazy var ballHitBrick     : UInt32 = self.ballCategory      | self.brickCategory
    lazy var ballHitDeadline  : UInt32 = self.deadlineCategory  | self.ballCategory
    lazy var brickHitDeadline : UInt32 = self.deadlineCategory  | self.brickCategory
    lazy var ballHitPaddle    : UInt32 = self.ballCategory      | self.playerCategory
    lazy var brickHitPaddle   : UInt32 = self.brickCategory     | self.playerCategory

    let scaleToNormal   = SKAction.scale(to: 0.5,   duration: 0.5)
    let scaleToNothing  = SKAction.scale(to: 0.001, duration: 0.2)
    let scaleToInfinity = SKAction.scale(to: 50, duration: 1.0)
    
    var controller = Controller()

    var gkScene: GKScene?
    var scene: GameScene?
    var physicsBody: SKPhysicsBody?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        gkScene = GKScene(fileNamed: "GameScene")
        if gkScene != nil {
            // Get the SKScene from the loaded GKScene
            scene = gkScene?.rootNode as! GameScene?
            if scene != nil {
                // Copy gameplay related content over to the scene
                scene?.entities = (gkScene?.entities)!
                scene?.graphs = (gkScene?.graphs)!
                
                // Set the scale mode to scale to fit the window
                scene?.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(scene)
                    
                    view.ignoresSiblingOrder = true
                    
//                    view.showsFPS       = true
//                    view.showsNodeCount = true
//                    view.showsPhysics   = true
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // playfield
        scene?.physicsWorld.contactDelegate = self
        
        physicsBody                  = SKPhysicsBody(edgeLoopFrom: (scene?.frame)!)
        physicsBody!.friction        = 0.0
        physicsBody!.categoryBitMask = playfieldCategory
        scene?.physicsBody           = physicsBody
        
        message.text      = "Ready Player One"
        message.fontSize  = 65
        message.position  = CGPoint(x:(scene?.frame.midX)!, y:(scene?.frame.midY)!)
        message.zPosition = 2.0
        scene?.addChild(message)
        
        scoreBoard.text     = ""
        scoreBoard.fontSize = 40
        scoreBoard.position = CGPoint(x: (scene?.frame.minX)! + 15, y: (scene?.frame.minY)! + 7)
        scoreBoard.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scene?.addChild(scoreBoard)

        // player
        player.position = CGPoint(x: 150 ,y: (scene?.frame.minY)! + 45)
        player.physicsBody!.categoryBitMask = playerCategory
        player.physicsBody!.contactTestBitMask = brickCategory
        scene?.addChild(player)
        
        // wall
        wallLeft.text = ""
        wallLeft.fontSize = 40
        wallLeft.position = CGPoint(x:(scene?.frame.maxX)! - 45, y: (scene?.frame.minY)! + 7)
        scene?.addChild(wallLeft)
        
        // deadline
        let deadline = SKShapeNode(rect: CGRect(x: (scene?.frame.minX)!, y: (scene?.frame.minY)!, width: (scene?.frame.maxX)! - (scene?.frame.minX)!, height: 2))
        deadline.fillColor = UIColor.red
        deadline.strokeColor = UIColor.red

        deadline.physicsBody = SKPhysicsBody(edgeLoopFrom: deadline.frame)
        deadline.physicsBody?.categoryBitMask = deadlineCategory
        scene?.addChild(deadline)
        
        controller.valueChangedHandler = controllerChangedHandler
        newGame()
    }
    
    // death of a brick
    func brickDie(_ brick: Brick) {
        brick.removeFromParent()
        
        wall.removeValue(forKey: brick)
        if wall.count == 0 {wallUp()}
        
        wallLeft.text   = "\(wall.count)"
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

                scene?.addChild(brick)
            }
        }
        
        wallLeft.text = "\(wall.count)"
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

    // collision resolution
    func didBegin(_ contact: SKPhysicsContact) {
        let all = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch all {
        case ballHitPlayfield:
            ball?.run(ballHitWallSound)
            ball?.kick()
            
        case ballHitDeadline:
            ball?.run(ballDeathknell)
            ball?.run(scaleToNothing, completion: {self.die()})
            
        case ballHitBrick:
            let brick = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            (brick.node as! Brick).removeAG()
            ball?.kick()
            
        case brickHitDeadline:
            let pBody = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            let brick = pBody.node! as! Brick
            
            let brickValue = brick.score()
            score += brickValue
            scoreBoard.text = "\(score)"
            let prize = SKLabelNode(fontNamed:"Chalkduster")
            prize.text = String(brickValue)
            prize.position = brick.position
            prize.fontSize = 10
            prize.zPosition = -1.0
            
            scene?.addChild(prize)
            prize.run(scaleToInfinity, completion: {prize.removeFromParent()})
            
            pBody.isDynamic = false // dead brick can't collide or die again
            brick.run(brickDeathknell)
            brick.run(scaleToNothing, completion: {self.brickDie(brick)})
        
        case ballHitPaddle:
            ball?.run(ballHitPaddleSound)
            ball?.kick()
            
        case brickHitPaddle:
            let pBody = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            let brick = pBody.node! as! Brick

            brick.run(brickHitPaddleSound)
            
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
    
    // controller handling
    func touchMoved(toPoint pos : CGPoint) {
        let x = pos.x * 2.0        
        let newpos = CGPoint(x: x, y: pos.y)
        player.moveTo(newpos)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchMoved(toPoint: t.location(in: scene!))
        }
    }
    
    func controllerChangedHandler(which: GCMicroGamepad, what: GCControllerElement) -> () {
        if let button = what as? GCControllerButtonInput {
            if button.isPressed == false {
                if (ball == nil) {
                    if (balls > 0) { // if no ball in play AND there are any left, launch one
                        message.isHidden = true
                        balls -= 1
                        if scene != nil {
                            ball = Ball(scene: scene!)
                        }
                        ball?.physicsBody!.categoryBitMask    = ballCategory
                        ball?.physicsBody!.contactTestBitMask = playfieldCategory | deadlineCategory | playerCategory | brickCategory
                        ball?.run(scaleToNormal)
                    }
                    else {
                        newGame()
                    }
                }
            }
        }
    }
}
