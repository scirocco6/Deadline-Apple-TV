//
//  SKShapeNode.swift
//  Deadline
//
//  Created by six on 12/25/16.
//  Copyright © 2016 six. All rights reserved.
//

import SpriteKit

class DeadLine: SKSpriteNode {

    let texture1 = SKTexture(imageNamed: "Lightning1")
    let texture2 = SKTexture(imageNamed: "Lightning2")

    init(scene: SKScene) {
        super.init(texture: texture1, color: UIColor.clear, size: CGSize(width: 1022.0, height: texture1.size().height))
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.affectedByGravity = false

        self.position = CGPoint(x: 1, y: scene.frame.minY + 40)
        
        let spark = SKAction.animate(with: [texture1, texture2], timePerFrame:0.3)
        let animation = SKAction.repeatForever(spark)
        run(animation)
        
        scene.addChild(self)
    }
    
    func randomizeColor() {
//        let red   = CGFloat(drand48())
//        let green = CGFloat(drand48())
//        let blue  = CGFloat(drand48())
//        
//        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//        
//        strokeColor = color
//        fillColor   = color
    }
    
    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
