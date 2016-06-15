//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Jesse Tayler on 6/14/16.
//  Copyright © 2016 OEI. All rights reserved.
//

import WatchKit
import Foundation
import SpriteKit

class InterfaceController: WKInterfaceController {

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    override func awake(withContext context: AnyObject?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        loadScene()
    }
    
    func loadScene() {
        let w: CGFloat = 640
        let h: CGFloat = 640
        var sceneSize = CGSize(width: w, height: h)

        let scene: SKScene = PongScene.init(size: sceneSize, controlStyle: nil)
        scene.scaleMode = .aspectFit
     //   presentScene(scene)
        skInterface.presentScene(scene)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
