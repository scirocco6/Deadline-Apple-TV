//
//  GameScene.swift
//  Deadline
//
//  Created by six on 11/2/16.
//  Copyright © 2016 six. All rights reserved.
//

import SpriteKit
import GameplayKit

public class GameScene: SKScene {
    var initialized = false // deal with sceneDidLoad is called twice due to scene editor bug :(
    
    let message    = SKLabelNode(fontNamed:"Chalkduster")
    let scoreBoard = SKLabelNode(fontNamed:"Chalkduster")
    let wallLeft   = SKLabelNode(fontNamed:"Chalkduster")

    var deadline: DeadLine?
    
    let sound = Sound()
    
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
        scoreBoard.fontSize = 40
        scoreBoard.position = CGPoint(x: (scene?.frame.minX)! + 15, y: (scene?.frame.minY)! + 7)
        scoreBoard.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(scoreBoard)
        
        // wallLeft
        wallLeft.text = ""
        wallLeft.fontSize = 40
        wallLeft.position = CGPoint(x:(scene?.frame.maxX)! - 45, y: (scene?.frame.minY)! + 7)
        addChild(wallLeft)
        
        // deadline
        deadline = DeadLine(scene: self)
        
        //player
        player.position = CGPoint(x: 150 ,y: (scene?.frame.minY)! + 45)
        addChild(player)
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
