//
//  Player.swift
//  breakout
//
//  Created by six on 6/4/14.
//  Copyright (c) 2014 six. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    //let image = "edgyPaddle"
    let image = "glowyPaddle"

    let texture0 = SKTexture(imageNamed: "glowyPaddle0")
    let texture1 = SKTexture(imageNamed: "glowyPaddle1")
    
    init() {
        super.init(texture: texture1, color: UIColor.clear, size: texture1.size())
        
        self.setScale(0.5)

        //self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = SKPhysicsBody(texture: texture0, size: CGSize(width: self.size.width, height: self.size.height) )
        
        self.physicsBody!.friction       = 0.5
        self.physicsBody!.isDynamic      = false
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.usesPreciseCollisionDetection = true
    }

    func moveTo(_ location: CGPoint) {
        let offset = self.size.width / 2
        let minX = (self.parent?.frame.minX)! + offset
        let maxX = (self.parent?.frame.maxX)! - offset

        var location = location
        
        if location.x < minX {
            location.x = minX
        }
        else {
            if location.x > maxX {
                location.x = maxX
            }
        }
        
        self.position.x = location.x
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
