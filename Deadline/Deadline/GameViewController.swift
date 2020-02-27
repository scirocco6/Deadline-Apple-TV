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
//import GameController

class GameViewController: UIViewController {
    var readyToPlay = false
//    var controller  = Controller()

    var scene: GameScene?
    
    // load and play the title scene
    // TODO: add an interuptable attract mode scene
    // then fade over to the actual game scene
    override func viewDidLoad() {
        guard
            let titleScene = TitleScene(fileNamed: "TitleScene"),
            let gkScene    = GKScene(fileNamed: "GameScene")
        else {return}
        
        super.viewDidLoad()
        
        scene = gkScene.rootNode as! GameScene?
        if scene != nil {
            // Set the scale mode to scale to fit the window
            scene?.scaleMode      = .aspectFill
            titleScene.scaleMode  = .aspectFill
            
            if let view = self.view as! SKView? {
                // show the title scene
                // wait for it to finish
                // then start the actual game scene
                view.presentScene(titleScene)
                self.perform(#selector(GameViewController.presentGame), with: nil, afterDelay: 4.0)
            }
        }
    }
    
    @objc func presentGame() {
        // cross fade from the title sequence to the game scene
        let crossFade = SKTransition.crossFade(withDuration: 1.0)
        crossFade.pausesIncomingScene = false
        crossFade.pausesOutgoingScene = false
        
        (self.view as! SKView?)?.presentScene(scene!, transition: crossFade)
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
        
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if scene?.ball == nil {
            scene?.newBall()
        }
    }
}
