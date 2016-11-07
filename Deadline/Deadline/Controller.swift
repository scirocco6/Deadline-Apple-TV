//
//  Controller.swift
//  Deadline
//
//  Created by six on 11/3/16.
//  Copyright © 2016 six. All rights reserved.
//

import Foundation
import GameController

protocol ControlDelegate {}


class Controller {
    var delegate: ControlDelegate?
    
    var controller: GCController?
    var dx: Float = 0.0
    var dy: Float = 0.0
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(Controller.handleControllerDidConnectNotification(_:)), name: NSNotification.Name.GCControllerDidConnect,    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Controller.handleControllerDidDisconnectNotification(_:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    @objc func handleControllerDidConnectNotification(_ notification: Notification) {
        //let connectedGameController = notification.object as! GCController
        
        controller = GCController.controllers().first
        if controller != nil {
            print("Controller detected")
            controller!.playerIndex = GCControllerPlayerIndex.index1
            controller!.microGamepad?.valueChangedHandler = somethingHappened
        }
    }
    
    @objc func handleControllerDidDisconnectNotification(_ notification: Notification) {
        let disconnectedGameController = notification.object as! GCController
        
        if disconnectedGameController == controller {
            controller = nil
        }
    }

    func somethingHappened(which: GCMicroGamepad, what: GCControllerElement) -> Void {
        print(what.description)
    }
}
