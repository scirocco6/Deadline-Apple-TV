//
//  Player.swift
//  breakout
//
//  Created by six on 6/4/14.
//  Copyright (c) 2014 six. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    var minX    : CGFloat = 0
    var maxX    : CGFloat = 0
    let y       : CGFloat = 50
    let image = "wooden_paddle"
    
    init() {
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        self.setScale(0.5)
        
        minX = self.size.width/2
        maxX = 1024 - self.size.width/2
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        self.physicsBody!.friction       = 0.5
        self.physicsBody!.isDynamic        = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.usesPreciseCollisionDetection = true
    }

    func moveTo(_ location: CGPoint) {
        var location = location
        location.y = y
        
        if location.x < minX {
            location.x = minX
        }
        else {
            if location.x > maxX {
                location.x = maxX
            }
        }
        
        self.position = location
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
