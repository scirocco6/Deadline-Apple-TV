//
//  Brick.swift
//  breakout
//
//  Created by six on 6/6/14.
//  Copyright (c) 2014 six. All rights reserved.
//

import SpriteKit

class Brick: SKSpriteNode {
    let image = "rainbow_brick"
    
    init(x: Int, y: Int) {
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        
        self.physicsBody!.isDynamic = true
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.usesPreciseCollisionDetection = true
        
        self.position = CGPoint(x: x, y: y)
    }
    
    // the faster the brick was moving the more points!!@
    func score() -> Int {
        let currentVelocity = self.physicsBody!.velocity
        let dx = abs(currentVelocity.dx)
        let dy = abs(currentVelocity.dy)
        
        let score = dx > dy ? Int(dx) : Int(dy)
        
        print("\(score) points")
        return score
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
