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
//import AVFoundation

class InterfaceController: WKInterfaceController, WKCrownDelegate {

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    var totalMovement = 0.0
    let watchPongScene: WatchPongScene = WatchPongScene.init(size: CGSize(width: 640, height: 640), controlStyle: nil) as WatchPongScene

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadScene()
    }
     
    func loadScene() {
        watchPongScene.scaleMode = .aspectFit
        crownSequencer.delegate = self
        skInterface.presentScene(watchPongScene)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double)
    {
//        print(rotationalDelta)
        totalMovement = min(rotationalDelta, Double(1))
        watchPongScene.movePaddle1(totalMovement)
    }

    override func didAppear() {
        crownSequencer.focus()
    }
    

}
