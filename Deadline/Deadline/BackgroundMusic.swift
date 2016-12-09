//
//  BackgroundMusic.swift
//  Deadline
//
//  Created by six on 12/8/16.
//  Copyright © 2016 six. All rights reserved.
//

import Foundation
import AVFoundation

class BackGroundMusic {
    static let controller = BackGroundMusic()
    var audioPlayer: AVAudioPlayer?
    
    func playBackgroundMusic() {
        let aSound = URL(fileURLWithPath: Bundle.main.path(forResource: "SpaceEmergency", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:aSound)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            print("Cannot play the file")
        }
    }
}
