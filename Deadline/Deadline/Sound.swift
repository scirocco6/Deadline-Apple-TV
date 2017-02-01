//
//  Sound.swift
//  Deadline
//
//  Created by six on 12/25/16.
//  Copyright © 2016 six. All rights reserved.
//

import Foundation
import SpriteKit

class Sound {
    let oneUpSound             = SKAction.playSoundFileNamed("1Up.mp3",                  waitForCompletion: false)

    let ballHitPaddleSound   = SKAction.playSoundFileNamed("ball_hits_paddle.mp3",     waitForCompletion: false)
    let ballHitWallSound     = SKAction.playSoundFileNamed("ball_hit_wall.mp3",        waitForCompletion: false)
    let ballDeathknellSound  = SKAction.playSoundFileNamed("ball_hits_deadline.mp3",   waitForCompletion: false)
    let brickDeathknellSound = SKAction.playSoundFileNamed("brick_hits_deadline2.mp3", waitForCompletion: false)
    
    let brickLearnsGravitySound = SKAction.playSoundFileNamed("brick_learns_gravity.mp3", waitForCompletion: false)
    let fallingBrickHitSound    = SKAction.playSoundFileNamed("brick_learns_gravity.mp3", waitForCompletion: false)
    
    static var scene: SKScene?
    
    var soundChannels = ["1", "2", "3"]

    func play(_ play: SKAction) {
        guard let channel = soundChannels.popLast() else {return}
        
        Sound.scene?.run(play, withKey: channel)
        soundChannels.insert(channel, at: 0)
    }
    
    func oneUp()           {play(oneUpSound)}
    func ballHitPaddle()   {play(ballHitPaddleSound)}
    func ballHitWall()     {play(ballHitWallSound)}
    func ballDeathknell()  {play(ballDeathknellSound)}
    func brickDeathknell() {play(brickDeathknellSound)}
    
    func brickLearnsGravity() {play(brickLearnsGravitySound)}
    func fallingBrickHit()    {play(fallingBrickHitSound)}

}

