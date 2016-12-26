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



class GameViewController: UIViewController {
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
        
        controller.valueChangedHandler = controllerChangedHandler
        readyToPlay = true
        
        scene?.startGame()
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
            scene?.newGame()
        }
    }
}
