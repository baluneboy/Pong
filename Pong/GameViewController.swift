//
//  GameViewController.swift
//  Pong
//
//  Created by Jesse Tayler on 12/9/15.
//  Copyright (c) 2015 OEI. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView: SKView = view as? SKView {
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            let scene: SKScene = PongScene.init(size: skView.bounds.size,controlStyle: nil)
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
    }
}
