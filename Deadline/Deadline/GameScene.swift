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
    var deadline: DeadLine?

    private var lastUpdateTime : TimeInterval = 0

    override public func sceneDidLoad() {
        deadline = DeadLine(scene: self)
    }
    
    override public func update(_ currentTime: TimeInterval) { // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {self.lastUpdateTime = currentTime}
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        if dt > 0.1 {
            deadline?.randomizeColor()
            self.lastUpdateTime = currentTime
        }
    }
}
