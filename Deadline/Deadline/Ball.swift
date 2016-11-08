//
//  Ball.swift
//  breakout
//
//  Created by six on 6/4/14.
//  Copyright (c) 2014 six. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
    var minX:  CGFloat  = 0
    var maxX:  CGFloat  = 0
    let minV:  CGFloat  = 400
    let maxV:  CGFloat  = 700
    let minVx: CGFloat  = 15
  
    let pulseUp         = SKAction.scale(to: 0.6,   duration: 0.1)
    let pulseDown       = SKAction.scale(to: 0.5,   duration: 0.1)
  
    let image           = "glowing_ball"
    
    init(scene: SKScene) {
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())

        self.setScale(0.5)
        
        let offset = self.size.width / 2
        minX = scene.frame.minX + offset
        maxX = scene.frame.maxX - offset

        let x  = CGFloat(arc4random_uniform(UInt32(maxX - minX))) + CGFloat(minX)
        let dx = CGFloat(arc4random_uniform(400)) - 200
    
        self.position = CGPoint(x: x, y: 0)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius:self.size.width/2 - 3)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.allowsRotation     = false
        
        self.physicsBody!.friction           = 0.0
        self.physicsBody!.linearDamping      = 0.0
        self.physicsBody!.angularDamping     = 0
        
        self.physicsBody!.isDynamic          = true
        self.physicsBody!.affectedByGravity  = false
        self.physicsBody!.velocity           = CGVector(dx: dx, dy: -300)
        
        self.physicsBody!.restitution        = 1.05 // gain a little speed every hit
        self.setScale(0.001)
        
        scene.addChild(self)
    }
    
    func kick() {
        self.run(pulseUp, completion: {self.run(self.pulseDown)})

        let currentVelocity = self.physicsBody!.velocity
        
        print("ping! \(currentVelocity.dx) \(currentVelocity.dy)")

        
        var newDX = currentVelocity.dx //* 1.05 is added via restitution instead of here
        var newDY = currentVelocity.dy //* 1.05
        
        if abs(newDX) > maxV {
            newDX = newDX < 0 ? -maxV : maxV
        }
        else if abs(newDX) < minVx {
            newDX = newDX < 0 ? -minVx : minVx
        }
        
        if abs(newDY) > maxV {
            newDY = newDY < 0 ? -maxV : maxV
        }
        else if abs(newDY) < minV {
            newDY = newDY < 0 ? -minV : minV
        }

        self.physicsBody!.velocity = CGVector(dx: newDX, dy: newDY)
        
        print("pong! \(newDX) \(newDY)")
        
    }
    
    func shouldDie() -> Bool {
        if self.position.y <= self.parent!.frame.minY + self.size.width / 2 + 5 {
            return true
        }
        else {
            return false
        }
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
