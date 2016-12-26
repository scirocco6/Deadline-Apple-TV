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
    let scaleToInfinity = SKAction.scale(to: 5,     duration: 1.0)
    
    var controller = Controller()

    var scene: GameScene?
    var physicsBody: SKPhysicsBody?
    
    var readyToPlay = false
    
    // load and play the title scene
    // TODO: add an interuptable attract mode scene
    // then fade over to the actual game scene
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let titleScene = TitleScene(fileNamed: "TitleScene") {
            if let gkScene = GKScene(fileNamed: "GameScene") {
                scene = gkScene.rootNode as! GameScene?
                if scene != nil {
                    // Set the scale mode to scale to fit the window
                    scene?.scaleMode      = .aspectFill
                    titleScene.scaleMode  = .aspectFill
                    
                    // Present the actual game scene
                    if let view = self.view as! SKView? {
                        // show the title scene
                        // wait for it to finish
                        // then start the actual game scene
                        view.presentScene(titleScene)
                        self.perform(#selector(GameViewController.startGame), with: nil, afterDelay: 4.0)
                    }
                }
            }
        }
    }

    func startGame() {
        // cross fade from the title sequence to the game scene
        let crossFade = SKTransition.crossFade(withDuration: 1.0)
        crossFade.pausesIncomingScene = false
        crossFade.pausesOutgoingScene = false
        
        (self.view as! SKView?)?.presentScene(scene!, transition: crossFade)
        
        // playfield
        scene?.physicsWorld.contactDelegate = self
        
        physicsBody                  = SKPhysicsBody(edgeLoopFrom: (scene?.frame)!)
        physicsBody!.friction        = 0.0
        physicsBody!.categoryBitMask = playfieldCategory
        scene?.physicsBody           = physicsBody
        
        // player
        scene?.player.physicsBody!.categoryBitMask = playerCategory
        scene?.player.physicsBody!.contactTestBitMask = brickCategory
        
        // deadline
        scene?.deadline?.physicsBody?.categoryBitMask = deadlineCategory

        controller.valueChangedHandler = controllerChangedHandler
        readyToPlay = true
        newGame()
    }
    
    // death of a brick
    func scoreAndRemoveBrick(_ brick: Brick, multiplier: Int) {
        guard (brick.userData?["dying"]) as? Bool == false else {return} // dying bricks shouldn't die again
        brick.userData?["dying"] = true
        
        let brickValue = brick.score() * multiplier
        scene?.score += brickValue
        scene?.scoreBoard.text = "\((scene?.score)!)"
        let prize = SKLabelNode(fontNamed:"Chalkduster")
        prize.text = String(brickValue)
        prize.position = brick.position
        prize.fontSize = 10
        prize.zPosition = -1.0
        
        scene?.addChild(prize)
        prize.run(scaleToInfinity, completion: {prize.removeFromParent()})
        
        brick.physicsBody?.isDynamic = false // dead bricks can't collide again
        
        //sound.run(brickDeathknell)
        scene?.sound.brickDeathknell()
        brick.run(scaleToNothing, completion: {self.brickDie(brick)})
    }
    
    func brickDie(_ brick: Brick) {
        brick.removeFromParent()
        
        _ = scene?.wall.removeValue(forKey: brick)
        if scene?.wall.count == 0 {wallUp()}
        
        scene?.wallLeft.text   = "\((scene?.wall.count)!)"
    }

    // new wall
    func wallUp() {
        let leftX = Int(scene!.frame.minX)
        let topY = Int(scene!.frame.maxY)
        
        for y in stride(from: topY - 50, to: topY - 170, by: -30) {
            for x in stride(from: leftX + 90, to: leftX + 950, by: 70) {
                let brick = Brick(x: x, y: y)
                scene?.wall[brick] = true
                
                brick.physicsBody!.categoryBitMask    = brickCategory
                brick.physicsBody!.contactTestBitMask = deadlineCategory

                scene?.addChild(brick)
            }
        }
        
        scene?.wallLeft.text = "\((scene?.wall.count)!)"
    }
    
    // new game
    func newGame() {
        for (brick, _) in (scene?.wall)! {brickDie(brick)}
        
        if scene?.wall.count == 0 {wallUp()}
        
        scene?.score  = 0
        scene?.balls  = 3
        scene?.inPlay = false
        
        if scene?.ball != nil {
            scene?.ball!.removeFromParent()
            scene?.ball = nil
        }
        
        scene?.scoreBoard.text  = "0"
        scene?.message.text     = "Ready Player One"
        scene?.message.isHidden = false
    }

    // collision resolution
    func didBegin(_ contact: SKPhysicsContact) {
        let all = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch all {
        case ballHitPlayfield:
            scene?.sound.ballHitWall()
            scene?.ball?.kick()
            
        case ballHitDeadline:
            scene?.sound.ballDeathknell()
            scene?.ball?.run(scaleToNothing, completion: {self.die()})
            
        case ballHitBrick:
            let brick = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            (brick.node as! Brick).removeAG()
            scene?.ball?.kick()
            
        case brickHitDeadline:
            let pBody = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            scoreAndRemoveBrick(pBody.node! as! Brick, multiplier: 1)
        
        case ballHitPaddle:
            scene?.sound.ballHitPaddle()
            scene?.ball?.kick()
            
        case brickHitPaddle:
            let pBody = contact.bodyA.categoryBitMask == brickCategory ? contact.bodyA : contact.bodyB
            scoreAndRemoveBrick(pBody.node! as! Brick, multiplier: 2)
            
        default:
            print("default collision")
            scene?.ball?.kick()
        }
    }
    
    // death of a player
    func die() {
        scene?.ball?.removeFromParent()
        scene?.ball = nil
        if scene?.balls == 0 {scene?.message.text = "Game Over"}
        scene?.message.isHidden = false
    }
    
    // controller handling
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchMoved(toPoint: t.location(in: scene!))
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        guard readyToPlay else {return}

        let x = pos.x * 2.0
        let newpos = CGPoint(x: x, y: pos.y)
        scene?.player.moveTo(newpos)
    }

    func controllerChangedHandler(which: GCMicroGamepad, what: GCControllerElement) -> () {
        guard
            let button = what as? GCControllerButtonInput,
            button.isPressed == false,
            scene?.ball == nil
        else {return}

        if ((scene?.balls)! > 0) { // if no ball in play AND there are any left, launch one
            scene?.message.isHidden = true
            scene?.balls -= 1
            if scene != nil {
                scene?.ball = Ball(scene: scene!)
            }
            scene?.ball?.physicsBody!.categoryBitMask    = ballCategory
            scene?.ball?.physicsBody!.contactTestBitMask = playfieldCategory | deadlineCategory | playerCategory | brickCategory
            scene?.ball?.run(scaleToNormal)
        }
        else {
            newGame()
        }
    }
}
