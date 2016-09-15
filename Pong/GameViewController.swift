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

class GameViewController: GCEventViewController {

    // Game controls
    internal var controllerDPad: GCControllerDirectionPad?
    internal var controllerStoredDirection = float2(0.0) // left/right up/down
    
    var scene:PongScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView: SKView = view as? SKView {
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            controllerUserInteractionEnabled = false
            
            scene = PongScene.init(size: skView.bounds.size)
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
            setupGameControllers()
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        scene.pressesBegan(presses, with: event)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        scene.pressesEnded(presses, with: event)
    }
}
