//
//  DeathContactLine.swift
//  Deadline
//
//  Created by six on 1/30/17.
//  Copyright © 2017 six. All rights reserved.
//

import SpriteKit

class DeathContactLine: SKShapeNode {
    var minX:  CGFloat  = 0
    var maxX:  CGFloat  = 0
    
    init(scene: SKScene) {
        super.init()
        
        minX = scene.frame.minX
        maxX = scene.frame.maxX
        
        let rect = CGRect(x: scene.frame.minX, y: scene.frame.minY + 14, width: scene.frame.maxX - scene.frame.minX, height: 1)
        self.path = CGPath(rect: rect, transform: nil)
        
        strokeColor = UIColor.clear
        fillColor   = UIColor.clear
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        scene.addChild(self)
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
