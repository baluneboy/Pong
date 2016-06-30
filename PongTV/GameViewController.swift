//
//  GameViewController.swift
//  PongTV
//
//  Created by Jesse Tayler on 12/9/15.
//  Copyright (c) 2015 OEI. All rights reserved.
//

import UIKit
import SpriteKit
import GameController
import AVFoundation

class GameViewController: UIViewController {

    // Game controls
    internal var controllerDPad: GCControllerDirectionPad?
    internal var controllerStoredDirection = float2(0.0) // left/right up/down
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView: SKView = view as? SKView {
            skView.showsFPS = false
            skView.showsNodeCount = false
            //            let raster = UIImage(named: "raster")
            //            skView.backgroundColor = UIColor(patternImage: raster!)
            //            p1ScoreNode.fontColor = UIColor(patternImage: raster!)
            
            //handle possible portrait rendering
            let w: CGFloat = skView.bounds.size.width
            let h: CGFloat = skView.bounds.size.height
            var sceneSize = CGSize(width: w, height: h)
            if h > w {
                sceneSize = CGSize(width: h, height: w)
            }
            
            let scene: SKScene = PongScene.init(size: sceneSize, controlStyle: nil)
            scene.scaleMode = .aspectFit
            
            //setupGameControllers()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {}
            
            skView.presentScene(scene)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.current().userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
