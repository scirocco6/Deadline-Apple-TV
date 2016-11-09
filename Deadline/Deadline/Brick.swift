//
//  Brick.swift
//  breakout
//
//  Created by six on 6/6/14.
//  Copyright (c) 2014 six. All rights reserved.
//

import SpriteKit

class Brick: SKSpriteNode {
    let agTexture = SKTexture(imageNamed: "rainbow_brick")
    let fallingTexture = SKTexture(imageNamed: "heavy_brick")
    let glassCrashSound = SKAction.playSoundFileNamed("glass_smash.mp3", waitForCompletion: false)

    
    init(x: Int, y: Int) {
        super.init(texture: agTexture, color: UIColor.clear, size: agTexture.size())
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        
        self.physicsBody!.isDynamic = true
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.usesPreciseCollisionDetection = true
        
        self.position = CGPoint(x: x, y: y)
    }
    
    func removeAG() {
        if self.physicsBody?.affectedByGravity == false {
            self.run(glassCrashSound)
            self.physicsBody?.affectedByGravity = true
            self.texture = fallingTexture
        }
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
