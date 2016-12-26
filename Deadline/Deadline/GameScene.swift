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
    let message = SKLabelNode(fontNamed:"Chalkduster")

    var deadline: DeadLine?
    
    private var lastUpdateTime : TimeInterval = 0

    override public func sceneDidLoad() {
        guard initialized == false else {return}
        initialized = true
        
        // message
        message.text      = "Ready Player One"
        message.fontSize  = 65
        message.position  = CGPoint(x:(scene?.frame.midX)!, y:(scene?.frame.midY)!)
        message.zPosition = 2.0
        self.addChild(message)
        
        // deadline
        deadline = DeadLine(scene: self)
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
