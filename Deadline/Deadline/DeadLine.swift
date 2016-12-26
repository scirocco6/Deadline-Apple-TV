//
//  SKShapeNode.swift
//  Deadline
//
//  Created by six on 12/25/16.
//  Copyright © 2016 six. All rights reserved.
//

import SpriteKit

class DeadLine: SKShapeNode {
    var minX:  CGFloat  = 0
    var maxX:  CGFloat  = 0

    init(scene: SKScene) {
        super.init()

        minX = scene.frame.minX
        maxX = scene.frame.maxX

        let rect = CGRect(x: scene.frame.minX, y: scene.frame.minY, width: scene.frame.maxX - scene.frame.minX, height: 2)
        self.path = CGPath(rect: rect, transform: nil)
        
        randomizeColor()
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        scene.addChild(self)
    }
    
    func randomizeColor() {
        let red   = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue  = CGFloat(drand48())
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        strokeColor = color
        fillColor   = color
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
