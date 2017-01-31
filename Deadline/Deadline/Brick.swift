//
//  Brick.swift
//  breakout
//
//  Created by six on 6/6/14.
//  Copyright (c) 2014 six. All rights reserved.
//

import SpriteKit

class Brick: SKSpriteNode {
    let agTexture      = SKTexture(imageNamed: "rainbow_brick")
    let fallingTexture = SKTexture(imageNamed: "heavy_brick")
    
    let player = Sound()
    
    init(x: Int, y: Int) {
        super.init(texture: agTexture, color: UIColor.clear, size: agTexture.size())
        
        self.userData = NSMutableDictionary()
        self.userData?["dying"] = false
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        
        self.physicsBody!.isDynamic = true
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.usesPreciseCollisionDetection = true
        
        self.position = CGPoint(x: x, y: y)
        self.zPosition = -5
    }
    
    func removeAG() {
        if self.physicsBody?.affectedByGravity == false {
            player.brickLearnsGravity()
            self.physicsBody?.affectedByGravity = true
            self.texture = fallingTexture
        }
        else {
            player.fallingBrickHit()
        }
    }
    
    // the faster the brick was moving the more points!!@
    func score() -> Int {
        let currentVelocity = self.physicsBody!.velocity
        let dx = abs(currentVelocity.dx)
        let dy = abs(currentVelocity.dy)
        
        var score = dx > dy ? Int(dx) : Int(dy)
        score += 5
        
        return score
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
