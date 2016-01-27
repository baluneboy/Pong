//
//  GameViewController.swift
//  Pong
//
//  Created by Jesse Tayler on 12/9/15.
//  Copyright (c) 2015 OEI. All rights reserved.
//

import UIKit
import SpriteKit
import GameController

class GameViewController: UIViewController {

    // Game controls
    internal var controllerDPad: GCControllerDirectionPad?
    internal var controllerStoredDirection = float2(0.0) // left/right up/down
    
    var scene:PongScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView: SKView = view as? SKView {
            skView.showsFPS = true
            skView.showsNodeCount = false
            
            scene = PongScene.init(size: skView.bounds.size,controlStyle: nil)
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)
            setupGameControllers()
        }
    }

    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        super.pressesBegan(presses, withEvent: event)
        scene.pressesBegan(presses, withEvent: event)
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        super.pressesEnded(presses, withEvent: event)
        scene.pressesEnded(presses, withEvent: event)
    }
}
