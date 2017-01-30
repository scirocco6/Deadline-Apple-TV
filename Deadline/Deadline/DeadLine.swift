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
    let texture3 = SKTexture(imageNamed: "Lightning3")
    let texture4 = SKTexture(imageNamed: "Lightning4")
    let texture5 = SKTexture(imageNamed: "Lightning5")
    let texture6 = SKTexture(imageNamed: "Lightning6")
    let texture7 = SKTexture(imageNamed: "Lightning7")
    let texture8 = SKTexture(imageNamed: "Lightning8")

    init(scene: SKScene) {
        super.init(texture: texture1, color: UIColor.clear, size: CGSize(width: 1022.0, height: texture1.size().height))
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.affectedByGravity = false

        self.position = CGPoint(x: 1, y: scene.frame.minY + 40)
        
        let spark = SKAction.animate(with: [texture1, texture2, texture3, texture4, texture5, texture6, texture7, texture8], timePerFrame:0.04)
        let animation = SKAction.repeatForever(spark)
        run(animation)
        
        scene.addChild(self)
    }

    // more shiny boilerplate
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
